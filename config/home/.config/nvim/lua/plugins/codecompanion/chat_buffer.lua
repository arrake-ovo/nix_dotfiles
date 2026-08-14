local api = vim.api
local uv = vim.uv or vim.loop

local M = {}

local STATUS_NS = api.nvim_create_namespace("CodeCompanionChatStatus")
local STATUS_GROUP = api.nvim_create_augroup("codecompanion.chat.status", { clear = true })
local SPINNER_FRAMES = { "-", "\\", "|", "/" }
local BOTTOM_SCROLL_PADDING = 5

local status_by_buf = {}
local setup_done = false

local function colemak_motions()
  local ok, colemak = pcall(require, "config.colemak")
  if ok and colemak.motions then
    return colemak.motions
  end

  return {
    left = "h",
    up = "k",
    down = "j",
    right = "l",
  }
end

local function move_window(direction)
  return function()
    vim.cmd("wincmd " .. direction)
  end
end

local function with_blank_eob(fillchars)
  local parts = {}
  local has_eob = false

  for _, part in ipairs(vim.split(fillchars or "", ",", { trimempty = true })) do
    if vim.startswith(part, "eob:") then
      if not has_eob then
        table.insert(parts, "eob: ")
        has_eob = true
      end
    else
      table.insert(parts, part)
    end
  end

  if not has_eob then
    table.insert(parts, "eob: ")
  end

  return table.concat(parts, ",")
end

local function event_bufnr(args)
  if args and args.data and args.data.bufnr and args.data.bufnr ~= 0 then
    return args.data.bufnr
  end
  if args and args.buf and args.buf ~= 0 then
    return args.buf
  end
  return nil
end

local function get_chat(bufnr)
  local ok, codecompanion = pcall(require, "codecompanion")
  if not ok then
    return nil
  end

  local chat = codecompanion.buf_get_chat(bufnr)
  if type(chat) == "table" and chat.bufnr then
    return chat
  end

  return nil
end

local function adapter_name(bufnr)
  local chat = get_chat(bufnr)
  local adapter = chat and chat.adapter or nil
  local name = adapter and (adapter.formatted_name or adapter.name) or "AI"

  if type(name) ~= "string" or name == "" then
    return "AI"
  end

  return name
end

local function stop_spinner(bufnr)
  local state = status_by_buf[bufnr]
  if not state or not state.timer then
    return
  end

  local timer = state.timer
  state.timer = nil

  pcall(function()
    timer:stop()
  end)
  pcall(function()
    timer:close()
  end)
end

local function clear_status(bufnr)
  if not bufnr then
    return
  end

  stop_spinner(bufnr)
  status_by_buf[bufnr] = nil

  if api.nvim_buf_is_valid(bufnr) then
    api.nvim_buf_clear_namespace(bufnr, STATUS_NS, 0, -1)
  end
end

local function apply_window_spacing(bufnr)
  if not bufnr or not api.nvim_buf_is_valid(bufnr) then
    return
  end

  for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
    if api.nvim_win_is_valid(winid) then
      pcall(api.nvim_set_option_value, "scrolloff", BOTTOM_SCROLL_PADDING, {
        scope = "local",
        win = winid,
      })

      local ok, fillchars = pcall(api.nvim_get_option_value, "fillchars", { scope = "local", win = winid })
      if ok then
        pcall(api.nvim_set_option_value, "fillchars", with_blank_eob(fillchars), {
          scope = "local",
          win = winid,
        })
      end
    end
  end
end

local function ensure_state(bufnr)
  local state = status_by_buf[bufnr]
  if state then
    return state
  end

  state = {
    adapter = adapter_name(bufnr),
    frame = 1,
    status = "ready",
    version = 0,
  }
  status_by_buf[bufnr] = state
  return state
end

local function status_text(state)
  local prefix = "[" .. (state.adapter or "AI") .. "] "

  if state.status == "requesting" then
    return prefix .. SPINNER_FRAMES[state.frame] .. " 请求中", "DiagnosticInfo"
  end
  if state.status == "done" then
    return prefix .. "已完成", "DiagnosticHint"
  end
  if state.status == "stopped" then
    return prefix .. "已停止", "DiagnosticWarn"
  end

  return prefix .. "等待输入", "Comment"
end

local function render_status(bufnr)
  if not api.nvim_buf_is_valid(bufnr) then
    clear_status(bufnr)
    return
  end

  local state = ensure_state(bufnr)
  state.adapter = adapter_name(bufnr)

  api.nvim_buf_clear_namespace(bufnr, STATUS_NS, 0, -1)

  local text, hl = status_text(state)
  local line = math.max(api.nvim_buf_line_count(bufnr) - 1, 0)

  api.nvim_buf_set_extmark(bufnr, STATUS_NS, line, 0, {
    virt_text = { { text, hl } },
    virt_text_pos = "eol",
    priority = 250,
  })
end

local function start_spinner(bufnr)
  local state = ensure_state(bufnr)

  stop_spinner(bufnr)

  local timer = uv.new_timer()
  if not timer then
    return
  end

  state.timer = timer
  timer:start(0, 120, vim.schedule_wrap(function()
    local current = status_by_buf[bufnr]
    if not current or current.status ~= "requesting" or not api.nvim_buf_is_valid(bufnr) then
      stop_spinner(bufnr)
      return
    end

    current.frame = (current.frame % #SPINNER_FRAMES) + 1
    render_status(bufnr)
  end))
end

local function schedule_ready(bufnr, version, previous_status)
  vim.defer_fn(function()
    local state = status_by_buf[bufnr]
    if not state or state.version ~= version or state.status ~= previous_status then
      return
    end

    state.version = state.version + 1
    state.status = "ready"
    state.frame = 1
    render_status(bufnr)
  end, 1400)
end

local function set_status(bufnr, status, opts)
  if not bufnr or not api.nvim_buf_is_valid(bufnr) then
    return
  end

  opts = opts or {}

  local state = ensure_state(bufnr)
  state.version = state.version + 1
  state.status = status
  state.frame = 1
  state.adapter = adapter_name(bufnr)

  if status == "requesting" then
    start_spinner(bufnr)
  else
    stop_spinner(bufnr)
  end

  render_status(bufnr)

  if opts.reset_after then
    schedule_ready(bufnr, state.version, status)
  end
end

function M.chat_keymaps()
  local motions = colemak_motions()

  return {
    window_up = {
      modes = { n = "<leader>w" .. motions.up },
      callback = move_window("k"),
      description = "[Window] Move Up",
    },
    window_down = {
      modes = { n = "<leader>w" .. motions.down },
      callback = move_window("j"),
      description = "[Window] Move Down",
    },
    window_left = {
      modes = { n = "<leader>w" .. motions.left },
      callback = move_window("h"),
      description = "[Window] Move Left",
    },
    window_right = {
      modes = { n = "<leader>w" .. motions.right },
      callback = move_window("l"),
      description = "[Window] Move Right",
    },
  }
end

function M.setup()
  if setup_done then
    return
  end
  setup_done = true

  api.nvim_create_autocmd("User", {
    group = STATUS_GROUP,
    pattern = "CodeCompanionChatCreated",
    callback = function(args)
      local bufnr = event_bufnr(args)
      apply_window_spacing(bufnr)
      set_status(bufnr, "ready")
    end,
  })

  api.nvim_create_autocmd("User", {
    group = STATUS_GROUP,
    pattern = "CodeCompanionChatSubmitted",
    callback = function(args)
      set_status(event_bufnr(args), "requesting")
    end,
  })

  api.nvim_create_autocmd("User", {
    group = STATUS_GROUP,
    pattern = "CodeCompanionChatDone",
    callback = function(args)
      set_status(event_bufnr(args), "done", { reset_after = true })
    end,
  })

  api.nvim_create_autocmd("User", {
    group = STATUS_GROUP,
    pattern = "CodeCompanionChatStopped",
    callback = function(args)
      set_status(event_bufnr(args), "stopped", { reset_after = true })
    end,
  })

  api.nvim_create_autocmd("User", {
    group = STATUS_GROUP,
    pattern = {
      "CodeCompanionChatAdapter",
      "CodeCompanionChatModel",
      "CodeCompanionChatOpened",
      "CodeCompanionChatRestored",
    },
    callback = function(args)
      local bufnr = event_bufnr(args)
      if not bufnr or not status_by_buf[bufnr] then
        return
      end

      apply_window_spacing(bufnr)
      render_status(bufnr)
    end,
  })

  api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWinEnter", "WinEnter" }, {
    group = STATUS_GROUP,
    callback = function(args)
      if not status_by_buf[args.buf] then
        return
      end

      apply_window_spacing(args.buf)
      render_status(args.buf)
    end,
  })

  api.nvim_create_autocmd("User", {
    group = STATUS_GROUP,
    pattern = "CodeCompanionChatClosed",
    callback = function(args)
      clear_status(event_bufnr(args))
    end,
  })

  api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = STATUS_GROUP,
    callback = function(args)
      if status_by_buf[args.buf] then
        clear_status(args.buf)
      end
    end,
  })
end

return M

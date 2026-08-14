local adapters = require("plugins.codecompanion.adapters")

local M = {}

local function escape_prompt(prompt)
  return vim.fn.escape((prompt or ""):gsub("[%r\n]+", " "), [[\|]])
end

local function current_visual_selection_text()
  local context = require("codecompanion.utils.context")
  local lines = select(1, context.get_visual_selection(vim.api.nvim_get_current_buf()))

  return table.concat(lines or {}, "\n")
end

local function is_normal_mode(mode)
  return mode == "n" or mode == "no" or mode == "nov" or mode == "noV" or mode == "no\22"
end

local function current_buffer_reference()
  local bufnr = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(bufnr)
  local relative_path = vim.fn.fnamemodify(name, ":.")
  local filename = vim.fn.fnamemodify(name, ":t")
  local filetype = require("codecompanion.utils.context").get_filetype(bufnr)

  return {
    filetype = filetype,
    filename = filename ~= "" and filename or relative_path,
    path = relative_path ~= "" and relative_path or filename,
  }
end

local function format_selection_reference(text)
  text = vim.trim(text or "")
  if text == "" then
    return ""
  end

  local ref = current_buffer_reference()
  local fence = "````"

  if ref.filetype and ref.filetype ~= "" then
    fence = fence .. ref.filetype
  end
  if ref.path and ref.path ~= "" then
    fence = fence .. " {" .. ref.path .. "}"
  end

  if ref.filename and ref.filename ~= "" then
    return string.format("From `%s`:\n\n%s\n%s\n````", ref.filename, fence, text)
  end

  return string.format("%s\n%s\n````", fence, text)
end

local function focus_input_window(bufnr, winnr, keep_normal_mode)
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(winnr) then
      return
    end

    local last_line_number = math.max(vim.api.nvim_buf_line_count(bufnr), 1)
    local last_line = vim.api.nvim_buf_get_lines(bufnr, last_line_number - 1, last_line_number, false)[1] or ""

    vim.api.nvim_set_current_win(winnr)
    pcall(vim.api.nvim_win_set_cursor, winnr, { last_line_number, vim.fn.strchars(last_line) })

    if keep_normal_mode then
      vim.cmd("stopinsert")
    end
  end)
end

local function ensure_chat_ready()
  local codecompanion = require("codecompanion")
  local utils = require("codecompanion.utils")
  local chat = codecompanion.last_chat()

  if not chat then
    chat = codecompanion.chat()
  end

  if not chat then
    utils.notify("Could not create a CodeCompanion chat buffer", vim.log.levels.ERROR)
    return nil
  end

  if chat.current_request then
    utils.notify("Wait for the current CodeCompanion response to finish first", vim.log.levels.WARN)
    return nil
  end

  chat.ui:open()
  return chat
end

local function append_text_to_chat(text)
  text = vim.trim(text or "")
  if text == "" then
    return
  end

  local config = require("codecompanion.config")
  local chat = ensure_chat_ready()
  if not chat then
    return
  end

  chat:add_buf_message({
    role = config.constants.USER_ROLE,
    content = text,
  })
end

local function open_append_to_chat_input(initial_content, opts)
  opts = opts or {}
  local keep_normal_mode = is_normal_mode(opts.launch_mode or vim.fn.mode())

  require("codecompanion.interactions.shared.input").open({
    title = " Add To CodeCompanion Chat ",
    initial_content = initial_content,
    on_open = function(bufnr, winnr)
      focus_input_window(bufnr, winnr, keep_normal_mode)
    end,
    on_submit = function(text)
      vim.schedule(function()
        append_text_to_chat(text)
      end)
    end,
  })
end

function M.run_visual_prompt(prompt)
  return function()
    vim.cmd("'<,'>CodeCompanion " .. escape_prompt(prompt))
  end
end

function M.prompt_inline(opts)
  opts = opts or {}

  vim.ui.input({
    prompt = opts.visual and "CodeCompanion (selection): " or "CodeCompanion: ",
  }, function(input)
    input = vim.trim(input or "")
    if input == "" then
      return
    end

    if opts.include_buffer then
      input = "#{buffer} " .. input
    end

    local command = "CodeCompanion " .. escape_prompt(input)
    if opts.visual then
      command = "'<,'>" .. command
    end
    vim.cmd(command)
  end)
end

function M.append_prompt_to_chat()
  open_append_to_chat_input("", {
    launch_mode = vim.fn.mode(),
  })
end

function M.append_selection_to_chat()
  local text = current_visual_selection_text()
  if vim.trim(text) == "" then
    vim.notify("No visual selection found", vim.log.levels.WARN)
    return
  end

  open_append_to_chat_input(format_selection_reference(text), {
    launch_mode = vim.fn.mode(),
  })
end

function M.open_chat_with_adapter(adapter)
  return function()
    local args = { "adapter=" .. adapter }

    if adapter == "codex" then
      local command = adapters.codex_command()
      if not command then
        vim.notify(
          "CodeCompanion codex adapter requires a codex-acp executable. Install the Zed codex-acp bridge or refresh your npx cache.",
          vim.log.levels.ERROR
        )
        return
      end

      table.insert(args, "command=default")
    end

    vim.cmd("CodeCompanionChat " .. table.concat(args, " "))
  end
end

function M.open_new_chat()
  require("codecompanion").chat()
end

return M

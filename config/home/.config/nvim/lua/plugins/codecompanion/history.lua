local settings = require("plugins.codecompanion.settings")
local path = require("plugins.codecompanion.path")
local storage = require("plugins.codecompanion.storage")
local adapters = require("plugins.codecompanion.adapters")

local uv = vim.uv or vim.loop

local M = {}

local session_cache = {}

local function format_timestamp(sec)
  if not sec then
    return nil
  end

  return os.date("!%Y-%m-%dT%H:%M:%SZ", sec)
end

local function stat_signature(stat)
  return table.concat({
    stat.size or 0,
    stat.mtime and stat.mtime.sec or 0,
    stat.mtime and stat.mtime.nsec or 0,
  }, ":")
end

local function collect_session_files(root, acc)
  if not uv.fs_stat(root) then
    return acc
  end

  for name, kind in vim.fs.dir(root) do
    local session_path = path.join_paths(root, name)

    if kind == "directory" then
      collect_session_files(session_path, acc)
    elseif kind == "file" and session_path:sub(-6) == ".jsonl" then
      table.insert(acc, session_path)
    end
  end

  return acc
end

local function decode_jsonl_line(line)
  if not line or line == "" then
    return nil
  end

  local ok, event = pcall(vim.json.decode, line)
  if not ok then
    return nil
  end

  return event
end

local function decode_jsonl_events(lines)
  local events = {}

  for _, line in ipairs(lines or {}) do
    local event = decode_jsonl_line(line)
    if event then
      table.insert(events, event)
    end
  end

  return events
end

local function trim_preview_text(text, max_chars)
  text = vim.trim((text or ""):gsub("\r", ""))
  text = text:gsub("\n\n\n+", "\n\n")

  if text == "" then
    return ""
  end

  if vim.fn.strchars(text) > max_chars then
    return vim.fn.strcharpart(text, 0, max_chars) .. "..."
  end

  return text
end

local function response_item_text(payload)
  local chunks = {}

  for _, item in ipairs(payload.content or {}) do
    if item.type == "input_text" or item.type == "output_text" then
      table.insert(chunks, item.text or "")
    end
  end

  return trim_preview_text(table.concat(chunks, "\n\n"), 400)
end

local function extract_visible_messages(events)
  local messages = {}
  local saw_event_messages = false

  for _, event in ipairs(events or {}) do
    if event.payload and event.type == "event_msg" then
      local kind
      local text

      if event.payload.type == "user_message" then
        kind = "user"
        text = event.payload.message
      elseif event.payload.type == "agent_message" then
        kind = "assistant"
        text = event.payload.message
      end

      text = trim_preview_text(text, 400)
      if kind and text ~= "" then
        saw_event_messages = true
        table.insert(messages, {
          kind = kind,
          text = text,
        })
      end
    end
  end

  if saw_event_messages then
    return messages
  end

  for _, event in ipairs(events or {}) do
    if event.type == "response_item" and event.payload and event.payload.type == "message" then
      local role = event.payload.role
      if role == "user" or role == "assistant" then
        local text = response_item_text(event.payload)
        if text ~= "" then
          table.insert(messages, {
            kind = role,
            text = text,
          })
        end
      end
    end
  end

  return messages
end

local function session_title_from_messages(messages)
  for _, message in ipairs(messages or {}) do
    if message.kind == "user" then
      return vim.fn.strcharpart(message.text, 0, 80)
    end
  end
end

local function session_project_name(cwd)
  if not cwd or cwd == "" then
    return nil
  end

  return vim.fn.fnamemodify(cwd, ":t")
end

local function session_preview_from_messages(session, messages)
  local title = session.title and session.title ~= "" and session.title or "Untitled Session"
  local lines = { "# " .. title }
  local meta = {}

  if session.updatedAt then
    table.insert(meta, "`Updated` " .. session.updatedAt)
  end
  if session.project and session.project ~= "" then
    table.insert(meta, "`Project` " .. session.project)
  end
  if #meta > 0 then
    table.insert(lines, "")
    table.insert(lines, table.concat(meta, "  "))
  end

  if session.cwd and session.cwd ~= "" then
    table.insert(lines, "")
    table.insert(lines, "`Dir` `" .. vim.fn.fnamemodify(session.cwd, ":~") .. "`")
  end

  table.insert(lines, "")
  table.insert(lines, "## Recent Conversation")
  table.insert(lines, "")

  if not messages or #messages == 0 then
    table.insert(lines, "_No readable conversation content found._")
    return table.concat(lines, "\n")
  end

  local start = math.max(1, #messages - 5)
  if start > 1 then
    table.insert(lines, "_Earlier messages omitted._")
    table.insert(lines, "")
  end

  for i = start, #messages do
    local message = messages[i]
    local role = message.kind == "user" and "You" or "Assistant"
    table.insert(lines, "### " .. role)
    table.insert(lines, "")
    table.insert(lines, trim_preview_text(message.text, 320))

    if i < #messages then
      table.insert(lines, "")
    end

    table.insert(lines, "")
  end

  return vim.trim(table.concat(lines, "\n"))
end

local function format_history_label(session)
  local utils = require("codecompanion.utils")
  local parts = {}
  local title = session.title and session.title ~= "" and session.title or session.sessionId

  if session.updatedAt then
    local ts = utils.parse_iso8601(session.updatedAt)
    if ts then
      table.insert(parts, "(" .. utils.make_relative(ts) .. ")")
    end
  end

  table.insert(parts, title)

  if session.project and session.project ~= "" then
    table.insert(parts, "[" .. session.project .. "]")
  end

  return table.concat(parts, " ")
end

local function format_history_preview(session)
  if session.preview and session.preview ~= "" then
    return session.preview
  end

  local title = session.title and session.title ~= "" and session.title or "Untitled Session"
  local lines = {
    "# " .. title,
    "",
    "- Session ID: `" .. session.sessionId .. "`",
  }

  if session.updatedAt then
    table.insert(lines, "- Updated At: `" .. session.updatedAt .. "`")
  end

  if session.cwd and session.cwd ~= "" then
    table.insert(lines, "- Working Dir: `" .. session.cwd .. "`")
  end

  return table.concat(lines, "\n")
end

local function build_session_from_file(session_path, stat)
  local lines = vim.fn.readfile(session_path)
  local events = decode_jsonl_events(lines)
  local first_event = events[1]
  if not first_event or first_event.type ~= "session_meta" or not first_event.payload then
    return nil
  end

  local messages = extract_visible_messages(events)
  local title = session_title_from_messages(messages)
  local updated_at_sec = stat and stat.mtime and stat.mtime.sec or 0
  local session = {
    sessionId = first_event.payload.id,
    title = title,
    cwd = first_event.payload.cwd,
    project = session_project_name(first_event.payload.cwd),
    updatedAt = format_timestamp(updated_at_sec),
    updatedAtSec = updated_at_sec,
  }

  session.preview = session_preview_from_messages(session, messages)
  return session
end

local function session_from_file(session_path)
  local stat = uv.fs_stat(session_path)
  if not stat then
    session_cache[session_path] = nil
    return nil
  end

  local signature = stat_signature(stat)
  local cached = session_cache[session_path]
  if cached and cached.signature == signature then
    return cached.session
  end

  local session = build_session_from_file(session_path, stat)
  if session and session.sessionId then
    session_cache[session_path] = {
      signature = signature,
      session = session,
    }
    return session
  end

  session_cache[session_path] = nil
  return nil
end

local function prune_session_cache(files)
  local active = {}

  for _, session_path in ipairs(files) do
    active[session_path] = true
  end

  for session_path in pairs(session_cache) do
    if not active[session_path] then
      session_cache[session_path] = nil
    end
  end
end

local function list_stored_sessions(opts)
  opts = opts or {}

  local sessions = {}
  local files = collect_session_files(path.join_paths(storage.codex_home(), "sessions"), {})

  prune_session_cache(files)

  for _, session_path in ipairs(files) do
    local session = session_from_file(session_path)
    if session and session.sessionId then
      table.insert(sessions, session)
    end
  end

  table.sort(sessions, function(a, b)
    return (a.updatedAtSec or 0) > (b.updatedAtSec or 0)
  end)

  local max_sessions = opts.max_sessions or 500
  if #sessions > max_sessions then
    return vim.list_slice(sessions, 1, max_sessions)
  end

  return sessions
end

function M.patch_acp_session_history()
  if not settings.share_history_across_projects then
    return
  end

  local ok, Connection = pcall(require, "codecompanion.acp")
  if not ok or Connection._shared_history_patch_applied then
    return
  end

  local original_session_list = Connection.session_list

  Connection.session_list = function(self, opts)
    if self.adapter and self.adapter.name == "codex" then
      return list_stored_sessions(opts)
    end

    return original_session_list(self, opts)
  end

  Connection._shared_history_patch_applied = true
end

function M.open_history_picker()
  local ok, Snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("CodeCompanion history picker requires snacks.nvim", vim.log.levels.ERROR)
    return
  end

  local utils = require("codecompanion.utils")
  local adapter = adapters.resolve_history_adapter()
  if not adapter or adapter.type ~= "acp" then
    utils.notify("History picker requires an ACP adapter such as Codex", vim.log.levels.WARN)
    return
  end

  local connection = require("codecompanion.acp").new({ adapter = adapter })
  if not connection:connect_and_authenticate() then
    utils.notify("Failed to connect to the ACP adapter", vim.log.levels.ERROR)
    return
  end

  if not connection:can_list_sessions() or not connection:can_load_session() then
    connection:disconnect()
    utils.notify("This ACP adapter does not support restoring session history", vim.log.levels.WARN)
    return
  end

  local sessions = connection:session_list({ max_sessions = 500 })
  if #sessions == 0 then
    connection:disconnect()
    utils.notify("No previous AI sessions found", vim.log.levels.INFO)
    return
  end

  local selected = false
  local items = vim.tbl_map(function(session)
    return {
      text = format_history_label(session),
      item = session,
      preview = {
        text = format_history_preview(session),
        ft = "markdown",
      },
    }
  end, sessions)

  Snacks.picker({
    items = items,
    title = "CodeCompanion History",
    preview = "preview",
    confirm = function(picker, item)
      if not item or not item.item then
        return
      end

      selected = true
      picker:close()

      local session = item.item
      local title = session.title and session.title ~= "" and session.title or session.sessionId
      local Chat = require("codecompanion.interactions.chat")
      local chat = Chat.new({
        hidden = true,
        title = title,
        adapter = adapter,
        buffer_context = {
          bufnr = vim.api.nvim_get_current_buf(),
        },
      })
      chat.acp_connection = connection

      local updates = {}
      local ok_load = connection:load_session(session.sessionId, {
        on_session_update = function(update)
          table.insert(updates, update)
        end,
      })

      if not ok_load then
        connection:disconnect()
        chat:close()
        utils.notify("Failed to load the selected AI session", vim.log.levels.ERROR)
        return
      end

      require("codecompanion.interactions.chat.acp.commands").link_buffer_to_session(chat.bufnr, connection.session_id)
      require("codecompanion.interactions.chat.acp.render").restore_session(chat, updates)

      if title and title ~= "" then
        chat:set_title(title)
      end

      Chat.close_last_chat()
      require("codecompanion").restore(chat.bufnr)
      utils.notify("Resumed session: " .. title)
    end,
    on_close = function()
      if not selected then
        connection:disconnect()
      end
    end,
    format = function(item)
      return { { item.text } }
    end,
  })
end

return M

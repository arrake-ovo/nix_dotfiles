local settings = require("plugins.codecompanion.settings")
local storage = require("plugins.codecompanion.storage")
local codex_acp = require("plugins.codex.acp")

local M = {}

function M.codex_command()
  return codex_acp.command()
end

function M.codex_command_args()
  local extra_args = {}

  if settings.codex_reasoning_effort and settings.codex_reasoning_effort ~= "" then
    table.insert(extra_args, "-c")
    table.insert(extra_args, string.format('model_reasoning_effort="%s"', settings.codex_reasoning_effort))
  end

  return codex_acp.argv(extra_args)
end

function M.interaction_adapter(adapter)
  if adapter == "codex" then
    return {
      name = "codex",
      model = settings.codex_model,
    }
  end

  return adapter
end

function M.resolve_history_adapter()
  local ok, codecompanion = pcall(require, "codecompanion")
  if ok then
    local chat = codecompanion.last_chat()
    if chat and chat.adapter and chat.adapter.type == "acp" then
      return chat.adapter
    end
  end

  local adapter_registry = require("codecompanion.adapters")
  local adapter = adapter_registry.resolve(M.interaction_adapter(settings.default_adapter))
  if adapter and adapter.type == "acp" then
    return adapter
  end

  return adapter_registry.resolve(M.interaction_adapter("codex"))
end

function M.codex_env()
  return {
    HOME = vim.env.HOME,
    PATH = vim.env.PATH,
    CODEX_HOME = storage.codex_home(),
    OPENAI_API_KEY = vim.env.OPENAI_API_KEY,
    CODEX_API_KEY = vim.env.CODEX_API_KEY,
  }
end

return M

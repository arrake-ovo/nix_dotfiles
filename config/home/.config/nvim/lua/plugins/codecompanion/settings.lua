local M = {
  -- Flip this to false when you want Lazy.nvim to skip loading CodeCompanion entirely.
  enabled = false,
  -- Keep CodeCompanion's Codex/Copilot state in this Neovim app instead of ~/.codex and ~/.config.
  isolate_from_global = true,
  -- Share one history across projects/directories inside this Neovim app.
  share_history_across_projects = true,
  default_adapter = "codex",
  codex_model = "gpt-5.4-mini",
  -- Supported by GPT-5.4 family in Codex: low | medium | high | xhigh
  codex_reasoning_effort = "xhigh",
  codex_auth_method = "chatgpt",
}

return M

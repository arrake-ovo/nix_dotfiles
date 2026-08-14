local settings = {
  -- Flip this to false when you want Lazy.nvim to skip loading agentic.nvim entirely.
  enabled = false,
  auth_method = "chatgpt",
  -- read-only / auto / full-access
  -- default_mode = "read-only",
  auto_scroll_threshold = 9999,
  diff_preview = true,
  window_position = "right",
  window_width = "42%",
}

local uv = vim.uv or vim.loop
local codex_acp = require("plugins.codex.acp")

local function home_dir()
  return uv.os_homedir() or vim.env.USERPROFILE or vim.env.HOME or ""
end

local function codex_home()
  if vim.env.CODEX_HOME and vim.env.CODEX_HOME ~= "" then
    return vim.env.CODEX_HOME
  end

  return home_dir() .. "/.codex"
end

return {
  {
    "carlos-algms/agentic.nvim",
    enabled = settings.enabled,
    event = "VeryLazy",
    opts = function()
      local resolved = codex_acp.resolve()

      return {
        provider = "codex-acp",
        acp_providers = {
          ["codex-acp"] = {
            command = resolved and resolved.command or "codex-acp",
            args = resolved and resolved.args or nil,
            auth_method = settings.auth_method,
            default_mode = settings.default_mode,
            env = {
              HOME = home_dir(),
              PATH = vim.env.PATH,
              CODEX_HOME = codex_home(),
              OPENAI_API_KEY = vim.env.OPENAI_API_KEY,
              CODEX_API_KEY = vim.env.CODEX_API_KEY,
            },
          },
        },
        auto_scroll = {
          threshold = settings.auto_scroll_threshold,
        },
        diff_preview = {
          enabled = settings.diff_preview,
        },
        windows = {
          position = settings.window_position,
          width = settings.window_width,
        },
      }
    end,
    keys = {
      {
        "<leader>aa",
        function()
          require("agentic").toggle()
        end,
        mode = { "n", "v", "i" },
        desc = "Agentic Toggle",
      },
      {
        "<leader>af",
        function()
          require("agentic").add_selection_or_file_to_context()
        end,
        mode = { "n", "v" },
        desc = "Agentic Add Context",
      },
      {
        "<leader>an",
        function()
          require("agentic").new_session()
        end,
        mode = { "n", "v", "i" },
        desc = "Agentic New Session",
      },
      {
        "<leader>ar",
        function()
          require("agentic").restore_session()
        end,
        mode = { "n", "v", "i" },
        desc = "Agentic Restore Session",
      },
      {
        "<leader>ad",
        function()
          require("agentic").add_current_line_diagnostics()
        end,
        mode = { "n" },
        desc = "Agentic Line Diagnostics",
      },
      {
        "<leader>aD",
        function()
          require("agentic").add_buffer_diagnostics()
        end,
        mode = { "n" },
        desc = "Agentic Buffer Diagnostics",
      },
    },
  },
}

return {
  {
    "coder/claudecode.nvim",
    event = "VeryLazy",
    opts = {
      port_range = { min = 10000, max = 65535 },
      auto_start = true,
      log_level = "info",
      terminal_cmd = nil,
      focus_after_send = false,
      track_selection = true,
      terminal = {
        split_side = "right",
        split_width_percentage = 0.30,
        provider = "auto",
        auto_close = true,
      },
      diff_opts = {
        layout = "vertical",
        open_in_new_tab = false,
      },
    },
    keys = {
      -- Group prefix (matches CodeCompanion <leader>a style)
      { "<leader>a", group = "ai|Claude Code", mode = { "n", "v" } },

      -- Terminal toggle/focus (most common actions)
      {
        "<leader>ac",
        "<cmd>ClaudeCode<cr>",
        mode = { "n", "v" },
        desc = "Claude Toggle Terminal",
      },
      {
        "<leader>af",
        "<cmd>ClaudeCodeFocus<cr>",
        mode = { "n", "v" },
        desc = "Claude Focus / Hide Terminal",
      },

      -- Continue / Resume
      {
        "<leader>aC",
        "<cmd>ClaudeCode --continue<cr>",
        mode = { "n", "v" },
        desc = "Claude Continue Generation",
      },
      {
        "<leader>ar",
        "<cmd>ClaudeCode --resume<cr>",
        mode = { "n", "v" },
        desc = "Claude Resume Session",
      },

      -- Model selection
      {
        "<leader>am",
        "<cmd>ClaudeCodeSelectModel<cr>",
        mode = { "n", "v" },
        desc = "Claude Select Model",
      },

      -- Context sending
      {
        "<leader>ab",
        function()
          vim.cmd("ClaudeCodeAdd " .. vim.fn.expand("%:p"))
        end,
        mode = { "n" },
        desc = "Claude Add Buffer",
      },
      {
        "<leader>as",
        "<cmd>ClaudeCodeSend<cr>",
        mode = { "v" },
        desc = "Claude Send Selection",
      },

      -- Diff management
      {
        "<leader>aa",
        "<cmd>ClaudeCodeDiffAccept<cr>",
        mode = { "n", "v" },
        desc = "Claude Accept Diff",
      },
      {
        "<leader>ad",
        "<cmd>ClaudeCodeDiffDeny<cr>",
        mode = { "n", "v" },
        desc = "Claude Deny Diff",
      },
    },
  },
}

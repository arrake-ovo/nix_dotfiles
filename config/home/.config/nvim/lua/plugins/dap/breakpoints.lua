-- Breakpoint-only behavior lives in this file.
-- We keep it separate from core.lua so "running the debugger" and
-- "managing breakpoints" stay easy to read and change independently.

local breakpoint_actions = require("plugins.dap.breakpoint_actions")

return {
  {
    "Weissle/persistent-breakpoints.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    opts = {
      -- Breakpoints should reappear as soon as an existing file is opened again.
      load_breakpoints_event = { "BufReadPost" },
    },
    config = function(_, opts)
      require("persistent-breakpoints").setup(opts)
    end,
    keys = {
      {
        "<leader>dB",
        function()
          breakpoint_actions.api().set_conditional_breakpoint()
        end,
        desc = "Breakpoint Condition",
      },
      {
        "<leader>db",
        function()
          breakpoint_actions.api().toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
      {
        "<leader>dm",
        function()
          breakpoint_actions.api().set_log_point()
        end,
        desc = "Log Point",
      },
      {
        "<leader>dp",
        function()
          breakpoint_actions.open_picker()
        end,
        desc = "Breakpoints Picker",
      },
      {
        "<leader>dX",
        function()
          breakpoint_actions.api().clear_all_breakpoints()
        end,
        desc = "Clear Breakpoints",
      },
    },
  },
}

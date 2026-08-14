local settings = require("plugins.codecompanion.settings")
local storage = require("plugins.codecompanion.storage")
local adapters = require("plugins.codecompanion.adapters")
local history = require("plugins.codecompanion.history")
local chat_input = require("plugins.codecompanion.chat_input")
local chat_buffer = require("plugins.codecompanion.chat_buffer")

return {
  {
    "olimorris/codecompanion.nvim",
    enabled = settings.enabled,
    cmd = {
      "CodeCompanion",
      "CodeCompanionActions",
      "CodeCompanionChat",
      "CodeCompanionCmd",
    },
    init = function()
      storage.bootstrap_isolated_state()
      vim.env.CODECOMPANION_TOKEN_PATH = storage.codecompanion_token_path()
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "zbirenbaum/copilot.lua",
    },
    opts = function()
      local codex_acp = adapters.codex_command_args()
      history.patch_acp_session_history()
      chat_buffer.setup()

      return {
        adapters = {
          http = {
            opts = {
              show_presets = false,
            },
            copilot = function()
              return require("codecompanion.adapters").extend("copilot", {})
            end,
          },
          acp = {
            opts = {
              show_presets = false,
            },
            codex = function()
              return require("codecompanion.adapters").extend("codex", {
                commands = codex_acp and {
                  default = codex_acp,
                } or nil,
                defaults = {
                  auth_method = settings.codex_auth_method,
                  model = settings.codex_model,
                },
                env = adapters.codex_env(),
              })
            end,
          },
        },
        interactions = {
          chat = {
            adapter = adapters.interaction_adapter(settings.default_adapter),
            keymaps = chat_buffer.chat_keymaps(),
          },
          inline = {
            adapter = adapters.interaction_adapter(settings.default_adapter),
          },
          cmd = {
            adapter = adapters.interaction_adapter(settings.default_adapter),
          },
        },
        display = {
          action_palette = {
            provider = "snacks",
          },
        },
      }
    end,
    keys = {
      {
        "<leader>ac",
        "<cmd>CodeCompanionChat Toggle<cr>",
        mode = { "n", "v" },
        desc = "CodeCompanion Chat",
      },
      {
        "<leader>aA",
        "<cmd>CodeCompanionActions<cr>",
        mode = { "n", "v" },
        desc = "CodeCompanion Actions",
      },
      {
        "<leader>aa",
        chat_input.append_prompt_to_chat,
        mode = { "n" },
        desc = "Append Text To Chat",
      },
      {
        "<leader>aa",
        chat_input.append_selection_to_chat,
        mode = { "v" },
        desc = "Append Selection To Chat",
      },
      {
        "<leader>ap",
        chat_input.open_chat_with_adapter("copilot"),
        mode = { "n" },
        desc = "CodeCompanion Copilot Chat",
      },
      {
        "<leader>an",
        chat_input.open_new_chat,
        mode = { "n" },
        desc = "CodeCompanion New Chat",
      },
      {
        "<leader>ak",
        chat_input.open_chat_with_adapter("codex"),
        mode = { "n" },
        desc = "CodeCompanion Codex Chat",
      },
      {
        "<leader>ai",
        function()
          chat_input.prompt_inline({ include_buffer = true })
        end,
        mode = { "n" },
        desc = "CodeCompanion Inline",
      },
      {
        "<leader>ai",
        function()
          chat_input.prompt_inline({ visual = true })
        end,
        mode = { "v" },
        desc = "CodeCompanion Inline",
      },
      {
        "<leader>ae",
        chat_input.run_visual_prompt("/explain"),
        mode = { "v" },
        desc = "Explain Selection",
      },
      {
        "<leader>ax",
        chat_input.run_visual_prompt("/fix"),
        mode = { "v" },
        desc = "Fix Selection",
      },
      {
        "<leader>at",
        chat_input.run_visual_prompt("/tests"),
        mode = { "v" },
        desc = "Test Selection",
      },
      {
        "<leader>am",
        "<cmd>CodeCompanionCmd<cr>",
        mode = { "n" },
        desc = "CodeCompanion Command",
      },
      {
        "<leader>ah",
        history.open_history_picker,
        mode = { "n" },
        desc = "CodeCompanion History",
      },
    },
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = function(_, opts)
      opts.spec = vim.list_extend(opts.spec or {}, {
        { "<leader>a", group = "ai", mode = { "n", "v" } },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts_extend = { "ensure_installed" },
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "nix",
        "markdown",
        "markdown_inline",
        "yaml",
      })
    end,
  },
}

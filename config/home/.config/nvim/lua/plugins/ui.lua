return {
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.preset = "classic"
      opts.keys = vim.tbl_deep_extend("force", opts.keys or {}, {
        scroll_down = "<C-e>",
        scroll_up = "<C-u>",
      })
      opts.triggers = {
        { "<auto>", mode = "nxso" },
        -- `t` and `q` are built-in normal-mode keys, so which-key won't
        -- create popup triggers for them automatically.
        { "t", mode = "n" },
        { "q", mode = "n" },
      }
      opts.spec = vim.list_extend(opts.spec or {}, {
        { "t", group = "tabs/buffers", mode = "n" },
        { "q", group = "quit", mode = "n" },
      })
    end,
  },
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      opts.highlights = opts.highlights or {}
      opts.highlights.buffer_selected = { italic = false, bold = false }
    end,
  },
  {
    "lazy.nvim",
    init = function()
      local view = require("lazy.view.config")

      view.keys = vim.tbl_deep_extend("force", view.keys or {}, {
        hover = "K",
        diff = "d",
        close = "Q",
        details = "<cr>",
        profile_sort = "<C-s>",
        profile_filter = "<C-f>",
        abort = "<C-c>",
        next = "]]",
        prev = "[[",
      })

      view.commands = vim.tbl_deep_extend("force", view.commands or {}, {
        home = {
          button = true,
          desc = "Go back to plugin list",
          id = 1,
          key = "n",
        },
        install = {
          button = true,
          desc = "Install missing plugins",
          desc_plugin = "Install a plugin",
          id = 2,
          key = "K",
          key_plugin = "k",
          plugins = true,
        },
        update = {
          button = true,
          desc = "Update plugins. This will also update the lockfile",
          desc_plugin = "Update a plugin. This will also update the lockfile",
          id = 3,
          key = "L",
          key_plugin = "l",
          plugins = true,
        },
        sync = {
          button = true,
          desc = "Run install, clean and update",
          desc_plugin = "Run install, clean and update",
          id = 4,
          key = "S",
          plugins = true,
        },
        clean = {
          button = true,
          desc = "Clean plugins that are no longer needed",
          desc_plugin = "Delete a plugin. WARNING: this will delete the plugin even if it should be installed!",
          id = 5,
          key = "X",
          key_plugin = "x",
          plugins = true,
        },
        check = {
          button = true,
          desc = "Check for updates and show the log (git fetch)",
          desc_plugin = "Check for updates and show the log (git fetch)",
          id = 6,
          key = "C",
          key_plugin = "c",
          plugins = true,
        },
        log = {
          button = true,
          desc = "Show recent updates",
          desc_plugin = "Show recent updates",
          id = 7,
          key = "G",
          key_plugin = "gl",
          plugins = true,
        },
        restore = {
          button = true,
          desc = "Updates all plugins to the state in the lockfile. For a single plugin: restore it to the state in the lockfile or to a given commit under the cursor",
          desc_plugin = "Restore a plugin to the state in the lockfile or to a given commit under the cursor",
          id = 8,
          key = "R",
          key_plugin = "r",
          plugins = true,
        },
        profile = {
          button = true,
          desc = "Show detailed profiling",
          id = 9,
          key = "P",
          toggle = true,
        },
        debug = {
          button = true,
          desc = "Show debug information",
          id = 10,
          key = "D",
          toggle = true,
        },
        help = {
          button = true,
          desc = "Toggle this help page",
          id = 11,
          key = "?",
          toggle = true,
        },
        clear = {
          desc = "Clear finished tasks",
          id = 12,
        },
        load = {
          desc = "Load a plugin that has not been loaded yet. Similar to `:packadd`. Like `:Lazy load foo.nvim`. Use `:Lazy! load` to skip `cond` checks.",
          id = 13,
          plugins = true,
          plugins_required = true,
        },
        health = {
          desc = "Run `:checkhealth lazy`",
          id = 14,
        },
        build = {
          desc = "Rebuild a plugin",
          id = 15,
          plugins = true,
          plugins_required = true,
          key_plugin = "gb",
        },
        reload = {
          desc = "Reload a plugin (experimental!!)",
          plugins = true,
          plugins_required = true,
          id = 16,
        },
      })
    end,
  },
}

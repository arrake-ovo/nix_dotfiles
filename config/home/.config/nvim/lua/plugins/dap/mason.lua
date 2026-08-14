local adapters = require("plugins.dap.adapters")

return {
  {
    "mason-org/mason.nvim",
    opts_extend = { "ensure_installed" },
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      -- Loading an adapter file means "this adapter is enabled".
      -- We let that enabled adapter declare which Mason package should be installed.
      vim.list_extend(opts.ensure_installed, adapters.mason_packages())
    end,
  },
}

local markdown_links = require("config.markdown_links")

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    keys = {
      {
        "gl",
        function()
          markdown_links.open_under_cursor()
        end,
        -- ft = { "markdown", "markdown.mdx" },
        desc = "Open Markdown Link",
      },
    },
    opts = function(_, opts)
      opts = opts or {}

      opts.code = vim.tbl_deep_extend("force", opts.code or {}, {
        sign = true,
        width = "full",
        right_pad = 0,
      })

      opts.heading = vim.tbl_deep_extend("force", opts.heading or {}, {
        sign = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      })

      opts.checkbox = vim.tbl_deep_extend("force", opts.checkbox or {}, {
        enabled = true,
      })
    end,
  },
}

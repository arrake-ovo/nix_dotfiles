return {
  {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    main = "colorizer",
    opts = {
      -- Enable color previews everywhere, so hex/RGB/HSL values in config,
      -- CSS, docs, and prose all get the same visual treatment.
      filetypes = { "*" },
      user_default_options = {
        css = true,
        css_fn = true,
        tailwind = true,
        -- Show a compact swatch after the color token instead of repainting
        -- the token background, which keeps code text readable.
        mode = "virtualtext",
        virtualtext = "■",
        virtualtext_inline = "after",
        virtualtext_mode = "foreground",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    opts = {
      move = {
        keys = {
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
            ["]a"] = "@parameter.inner",
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
            ["]A"] = "@parameter.inner",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
            ["[a"] = "@parameter.inner",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
            ["[A"] = "@parameter.inner",
          },
        },
      },
    },
  },
}

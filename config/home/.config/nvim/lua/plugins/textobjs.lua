return {
  {
    "chrisgrieser/nvim-various-textobjs",
    event = "VeryLazy",
    opts = {
      keymaps = {
        useDefaults = false,
      },
      forwardLooking = {
        small = 5,
        big = 15,
      },
    },
    config = function(_, opts)
      require("various-textobjs").setup(opts)
      local map = vim.keymap.set
      local to = function(name, ...)
        local args = { ... }
        return function()
          require("various-textobjs")[name](unpack(args))
        end
      end
      -- indentation
      map({ "o", "x" }, "fi", to("indentation", "inner", "inner"))
      map({ "o", "x" }, "ai", to("indentation", "outer", "inner"))
      map({ "o", "x" }, "fI", to("indentation", "inner", "outer"))
      map({ "o", "x" }, "aI", to("indentation", "outer", "outer"))
      -- subword
      map({ "o", "x" }, "fS", to("subword", "inner"))
      map({ "o", "x" }, "aS", to("subword", "outer"))
      -- value/key
      map({ "o", "x" }, "fv", to("value", "inner"))
      map({ "o", "x" }, "av", to("value", "outer"))
      map({ "o", "x" }, "fk", to("key", "inner"))
      map({ "o", "x" }, "ak", to("key", "outer"))
      -- chainMember (flash-enhanced)
      map({ "o", "x" }, "fm", function()
        require("plugins.textobjs.chain-member-flash").jump(true)
      end)
      map({ "o", "x" }, "am", function()
        require("plugins.textobjs.chain-member-flash").jump(false)
      end)
      -- number
      map({ "o", "x" }, "fn", to("number", "inner"))
      map({ "o", "x" }, "an", to("number", "outer"))
      -- url
      map({ "o", "x" }, "L", to("url"))
      -- anyBracket/anyQuote
      map({ "o", "x" }, "fo", to("anyBracket", "inner"))
      map({ "o", "x" }, "ao", to("anyBracket", "outer"))
      map({ "o", "x" }, "fq", to("anyQuote", "inner"))
      map({ "o", "x" }, "aq", to("anyQuote", "outer"))
      -- lineCharacterwise
      map({ "o", "x" }, "f_", to("lineCharacterwise", "inner"))
      map({ "o", "x" }, "a_", to("lineCharacterwise", "outer"))
      -- closedFold
      map({ "o", "x" }, "fz", to("closedFold", "inner"))
      map({ "o", "x" }, "az", to("closedFold", "outer"))
      -- color
      map({ "o", "x" }, "f#", to("color", "inner"))
      map({ "o", "x" }, "a#", to("color", "outer"))
    end,
  },
}
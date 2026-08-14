local motions = require("config.colemak").motions

local excluded_labels = table.concat({
  motions.left,
  motions.up,
  motions.down,
  motions.right,
  string.upper(motions.left),
  string.upper(motions.up),
  string.upper(motions.down),
  string.upper(motions.right),
})

local function flash_jump(opts)
  return function()
    require("flash").jump(opts)
  end
end

local function flash_treesitter_select()
  return function()
    require("flash").treesitter({
      actions = {
        [motions.down] = "next",
        [motions.up] = "prev",
      },
    })
  end
end

return {
  {
    "folke/flash.nvim",
    opts = {
      label = {
        exclude = excluded_labels,
      },
      modes = {
        search = {
          enabled = false,
        },
        char = {
          enabled = false,
        },
        treesitter_search = {
          search = {
            multi_window = false,
          },
        },
        remote = {
          remote_op = {
            restore = true,
            motion = true,
          },
        },
      },
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        flash_jump({
          search = {
            mode = "exact",
            multi_window = false,
            wrap = true,
          },
        }),
        desc = "Flash Jump",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<leader>sF",
        flash_jump({
          search = {
            mode = "search",
            multi_window = false,
            wrap = true,
          },
        }),
        desc = "Flash Search",
      },
      {
        "<leader>sf",
        flash_jump({
          search = {
            mode = "exact",
            multi_window = true,
            wrap = true,
          },
        }),
        desc = "Flash Across Windows",
      },
      {
        "<leader>sx",
        mode = { "n", "o", "x" },
        flash_treesitter_select(),
        desc = "Flash Treesitter Select",
      },
      {
        "<C-s>",
        mode = "c",
        function()
          local enabled = require("flash").toggle()
          vim.notify(enabled and "Flash Search on" or "Flash Search off", vim.log.levels.INFO, { title = "Flash" })
        end,
        desc = "Toggle Flash Search",
      },
    },
  },
}

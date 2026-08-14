local Colemak = require("config.colemak")
local motions = Colemak.motions

local function split_open(cmd, splitright, splitbelow)
  return function(picker, item)
    local Actions = require("snacks.picker.actions")
    local prev_right, prev_below = vim.o.splitright, vim.o.splitbelow
    vim.o.splitright = splitright
    vim.o.splitbelow = splitbelow
    local ok, err = pcall(Actions.jump, picker, item, { cmd = cmd })
    vim.o.splitright = prev_right
    vim.o.splitbelow = prev_below
    if not ok then
      error(err)
    end
  end
end
-- keymap see
-- snacks.nvim/picker/config/defaults.lua

return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        actions = {
          open_right = split_open("vsplit", true, vim.o.splitbelow),
          open_left = split_open("vsplit", false, vim.o.splitbelow),
          open_up = split_open("split", vim.o.splitright, false),
          open_down = split_open("split", vim.o.splitright, true),
          select_item = function(picker)
            picker.list:select()
          end,
          insert_input = function()
            vim.cmd("startinsert")
          end,
        },
        win = {
          input = {
            keys = {
              ["<C-e>"] = { "list_down", mode = { "i", "n" } },
              ["<C-u>"] = { "list_up", mode = { "i", "n" } },
              ["<C-n>"] = { "focus_list", mode = { "i", "n" } }, -- back to list
              ["<C-p>"] = { "focus_preview", mode = { "i", "n" } },
              ["h"] = { "focus_list", mode = "n" },
              ["p"] = { "focus_preview", mode = "n" },
              ["i"] = { "focus_preview", mode = "n" },
              ["k"] = "insert_input",
              ["u"] = false,
              ["e"] = false,
              ["n"] = false,
              -- ["i"] = false,
              ["<A-w>"] = false,
            },
          },
          list = {
            keys = {
              ["e"] = "list_down",
              ["u"] = "list_up",
              -- ["n"] = "cancel",
              ["i"] = "focus_preview",
              ["k"] = "focus_input",
              ["p"] = "focus_preview",
              ["W"] = "cycle_win",
              ["t"] = "tab",
              ["P"] = "toggle_preview",
              -- ["Q"] = "qflist",
              ["."] = "toggle_hidden",
              [","] = "toggle_ignored",
              -- ["<Space>"] = "select_item",
              ["si"] = "open_right",
              ["sn"] = "open_left",
              ["su"] = "open_up",
              ["se"] = "open_down",
              ["<A-w>"] = false,
            },
          },
          preview = {
            keys = {
              ["h"] = "focus_list",
              ["k"] = "focus_input",
              ["U"] = "preview_scroll_up",
              ["E"] = "preview_scroll_down",
              ["W"] = "cycle_win",
              ["u"] = false,
              ["e"] = false,
              ["i"] = false,
              ["n"] = false,
              ["<A-w>"] = false,
            },
          },
        },
        sources = {
          explorer = {
            layout = {
              preset = "sidebar",
              layout = {
                position = "right",
              },
            },
            win = {
              list = {
                keys = {
                  ["e"] = "list_down",
                  ["u"] = "list_up",
                  ["n"] = "explorer_close",
                  ["i"] = "confirm",
                  ["k"] = "focus_input",
                  ["p"] = "focus_preview",
                  ["W"] = "cycle_win",
                  ["t"] = "tab",
                  ["P"] = "toggle_preview",
                  -- ["Q"] = "qflist",
                  ["."] = "toggle_hidden",
                  [","] = "toggle_ignored",
                  -- ["<Space>"] = "select_item",
                  ["si"] = "open_right",
                  ["sn"] = "open_left",
                  ["su"] = "open_up",
                  ["se"] = "open_down",
                  ["U"] = "explorer_update",
                  ["<A-w>"] = false,
                },
              },
            },
          },
        },
      },
    },
  },
  {
    "nvim-mini/mini.files",
    opts = function(_, opts)
      opts.mappings = vim.tbl_deep_extend("force", opts.mappings or {}, {
        go_in = motions.right,
        go_in_plus = "<CR>",
        go_out = motions.left,
        go_out_plus = string.upper(motions.left),
      })
    end,
  },
}

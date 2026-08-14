local state_file = vim.fn.stdpath("state") .. "/theme.txt"
local default_colorscheme = "tokyonight"
local pending_colorscheme = nil

---@return {colorscheme: string, background?: string}?
local function read_colorscheme_state()
  local file = io.open(state_file, "r")
  if not file then
    return nil
  end

  local data = file:read("*a")
  file:close()

  local lines = vim.split(vim.trim(data), "\n", { plain = true, trimempty = true })
  local colorscheme = lines[1]
  local background = lines[2]

  if type(colorscheme) ~= "string" or colorscheme == "" then
    return nil
  end

  if background ~= "light" and background ~= "dark" then
    background = nil
  end

  return {
    colorscheme = colorscheme,
    background = background,
  }
end

---@param state {colorscheme?: string, background?: string}
local function write_colorscheme_state(state)
  local colorscheme = state.colorscheme
  if type(colorscheme) ~= "string" or colorscheme == "" then
    return
  end

  vim.fn.mkdir(vim.fn.fnamemodify(state_file, ":h"), "p")

  local file = io.open(state_file, "w")
  if not file then
    return
  end

  file:write(colorscheme .. "\n")
  if state.background == "light" or state.background == "dark" then
    file:write(state.background .. "\n")
  end
  file:close()
end

local function apply_colorscheme(colorscheme, background)
  pending_colorscheme = colorscheme
  if background == "light" or background == "dark" then
    vim.o.background = background
  end
  vim.cmd.colorscheme(colorscheme)
end

return {
  {
    "LazyVim/LazyVim",
    init = function()
      local group = vim.api.nvim_create_augroup("persist_colorscheme", { clear = true })
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = function()
          write_colorscheme_state({
            colorscheme = pending_colorscheme or vim.g.colors_name,
            background = vim.o.background,
          })
          pending_colorscheme = nil
        end,
      })
    end,
    opts = function(_, opts)
      opts.colorscheme = function()
        local state = read_colorscheme_state() or { colorscheme = default_colorscheme }
        local ok = pcall(apply_colorscheme, state.colorscheme, state.background)
        if not ok and state.colorscheme ~= default_colorscheme then
          apply_colorscheme(default_colorscheme)
        end
      end
    end,
  },
  {
    "folke/snacks.nvim",
    optional = true,
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts or {}, {
        picker = {
          sources = {
            colorschemes = {
              confirm = function(picker, item)
                picker:close()
                if item then
                  picker.preview.state.colorscheme = nil
                  vim.schedule(function()
                    apply_colorscheme(item.text)
                  end)
                end
              end,
            },
          },
        },
      })
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    opts = {
      transparent = false,
    },
  },
  {
    "polirritmico/monokai-nightasty.nvim",
    lazy = true,
  },
}

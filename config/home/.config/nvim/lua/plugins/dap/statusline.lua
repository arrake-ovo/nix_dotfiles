-- Show DEBUG in the normal mode position while debug mode is active.
-- Keeping this override in its own file makes it easy to remove or tweak
-- without touching the actual debugger behavior.

return {
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.sections = opts.sections or {}
      opts.sections.lualine_a = opts.sections.lualine_a or {}

      local current = opts.sections.lualine_a[1]
      local component = type(current) == "table" and vim.deepcopy(current) or { current or "mode" }
      local original_fmt = component.fmt
      local original_color = component.color

      component[1] = "mode"
      component.fmt = function(str)
        if vim.b.dap_debug_mode then
          return "DEBUG"
        end
        if type(original_fmt) == "function" then
          return original_fmt(str)
        end
        return str
      end

      component.color = function(...)
        if vim.b.dap_debug_mode then
          return { fg = Snacks.util.color("Debug"), gui = "bold" }
        end
        if type(original_color) == "function" then
          return original_color(...)
        end
        return original_color
      end

      opts.sections.lualine_a[1] = component
    end,
  },
}

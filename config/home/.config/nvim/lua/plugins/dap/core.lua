-- Core DAP behavior lives here.
-- Language adapters are configured separately and registered only after nvim-dap loads.
local adapters = require("plugins.dap.adapters")
local debug_mode = require("plugins.dap.debug_mode")

local function get_args(config)
  local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
  local args_text = type(args) == "table" and table.concat(args, " ") or args

  config = vim.deepcopy(config)
  config.args = function()
    local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_text))
    if config.type == "java" then
      return new_args
    end
    return require("dap.utils").splitstr(new_args)
  end

  return config
end

local function adapter_dependencies()
  local dependencies = {}

  for _, adapter in ipairs(adapters) do
    for _, dependency in ipairs(adapter.dependencies or {}) do
      table.insert(dependencies, dependency)
    end
  end

  return dependencies
end

local function adapter_keys()
  local keys = {}

  for _, adapter in ipairs(adapters) do
    for _, key in ipairs(adapter.keys or {}) do
      table.insert(keys, key)
    end
  end

  return keys
end

local function setup_vscode_launch_json_support()
  -- nvim-dap can reuse a project's `.vscode/launch.json`.
  -- VS Code allows comments in that file, so we strip comments before decoding.
  -- We keep this helper even though we do not call `load_launchjs()` by default,
  -- because it makes that workflow work the moment you decide to use launch.json.
  local vscode = require("dap.ext.vscode")
  local json = require("plenary.json")

  vscode.json_decode = function(text)
    return vim.json.decode(json.json_strip_comments(text))
  end
end

local function setup_dap_signs()
  vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

  for name, sign in pairs(LazyVim.config.icons.dap) do
    sign = type(sign) == "table" and sign or { sign }
    vim.fn.sign_define(
      "Dap" .. name,
      { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
    )
  end
end

return {
  {
    "mfussenegger/nvim-dap",
    desc = "Debugging support. Language adapters are enabled manually in plugins/dap/adapters/init.lua.",
    dependencies = vim.list_extend({
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "mfussenegger/nvim-dap-python",
    }, adapter_dependencies()),
    cmd = {
      "DapContinue",
      "DapToggleBreakpoint",
      "DapTerminate",
    },
    keys = vim.list_extend({
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Run/Continue",
      },
      {
        "<leader>dd",
        function()
          debug_mode.enter()
        end,
        desc = "Debug Mode",
      },
      {
        "<leader>da",
        function()
          require("dap").continue({ before = get_args })
        end,
        desc = "Run with Args",
      },
      {
        "<leader>dC",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "Run to Cursor",
      },
      {
        "<leader>dg",
        function()
          require("dap").goto_()
        end,
        desc = "Go to Line (No Execute)",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step Into",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Run Last",
      },
      {
        "<leader>do",
        function()
          require("dap").step_out()
        end,
        desc = "Step Out",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_over()
        end,
        desc = "Step Over",
      },
      {
        "<leader>dP",
        function()
          require("dap").pause()
        end,
        desc = "Pause",
      },
      {
        "<leader>dt",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Toggle REPL",
      },
      {
        "<leader>ds",
        function()
          require("dap").session()
        end,
        desc = "Session",
      },
      {
        "<leader>dx",
        function()
          require("dap").terminate()
          require("dapui").close({})
        end,
        desc = "Terminate",
      },
      {
        "<leader>dw",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "Widgets",
      },
      {
        "<leader>dq",
        function()
          local breakpoint_actions = require("plugins.dap.breakpoint_actions")
          breakpoint_actions.open_picker()
        end,
        desc = "Widgets",
      },
    }, adapter_keys()),
    config = function()
      local dap = require("dap")

      setup_dap_signs()
      setup_vscode_launch_json_support()
      debug_mode.setup(dap)

      -- Each enabled adapter gets one file.
      -- Keeping setup here means the adapters are registered only after nvim-dap itself loads.
      for _, adapter in ipairs(adapters) do
        adapter.setup(dap)
      end
    end,
  },
}

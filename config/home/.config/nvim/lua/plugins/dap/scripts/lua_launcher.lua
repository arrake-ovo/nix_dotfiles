-- This launcher bootstraps the local Lua debugger inside Neovim's Lua runtime.
-- It lets us debug a plain Lua file by running `nvim --headless -l`.
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  local debugger_path = os.getenv("LOCAL_LUA_DEBUGGER_FILEPATH")

  if debugger_path and debugger_path ~= "" then
    package.loaded["lldebugger"] = assert(loadfile(debugger_path))()
  end

  require("lldebugger").start()
end

local target = arg[1]
assert(target and target ~= "", "Missing Lua target file")

assert(loadfile(target))()

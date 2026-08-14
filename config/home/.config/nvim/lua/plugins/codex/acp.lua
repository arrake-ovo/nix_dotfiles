local uv = vim.uv or vim.loop

local M = {}

local resolved_command = nil

local function is_windows()
  return vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
end

local function normalize_path(path)
  local normalized = (path or ""):gsub("\\", "/")
  normalized = normalized:gsub("/+", "/")
  return normalized
end

local function join_paths(...)
  local parts = {}

  for i = 1, select("#", ...) do
    local part = select(i, ...)
    if part and part ~= "" then
      table.insert(parts, (normalize_path(part):gsub("/+$", "")))
    end
  end

  return table.concat(parts, "/")
end

local function home_dir()
  return uv.os_homedir() or vim.env.USERPROFILE or vim.env.HOME or ""
end

local function unique(items)
  local seen = {}
  local ret = {}

  for _, item in ipairs(items) do
    if item and item ~= "" and not seen[item] then
      seen[item] = true
      table.insert(ret, item)
    end
  end

  return ret
end

local function copy_list(items)
  local ret = {}

  for _, item in ipairs(items or {}) do
    table.insert(ret, item)
  end

  return ret
end

local function executable_on_path(candidates)
  for _, candidate in ipairs(candidates) do
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
end

local function latest_executable(paths)
  local best_path = nil
  local best_mtime = -1

  for _, path in ipairs(paths) do
    if vim.fn.executable(path) == 1 then
      local stat = uv.fs_stat(path)
      local mtime = 0

      if stat and stat.mtime then
        mtime = ((stat.mtime.sec or 0) * 1000000000) + (stat.mtime.nsec or 0)
      end

      if not best_path or mtime > best_mtime then
        best_path = path
        best_mtime = mtime
      end
    end
  end

  return best_path
end

local function npm_cache_roots()
  return unique({
    vim.env.NPM_CONFIG_CACHE,
    join_paths(home_dir(), ".npm"),
    join_paths(vim.env.LOCALAPPDATA, "npm-cache"),
    join_paths(vim.env.APPDATA, "npm-cache"),
  })
end

local function cached_codex_acp()
  local patterns = {}

  for _, root in ipairs(npm_cache_roots()) do
    vim.list_extend(patterns, {
      join_paths(root, "_npx", "*", "node_modules", ".bin", "codex-acp"),
      join_paths(root, "_npx", "*", "node_modules", ".bin", "codex-acp.cmd"),
      join_paths(root, "_npx", "*", "node_modules", ".bin", "codex-acp.exe"),
      join_paths(
        root,
        "_npx",
        "*",
        "node_modules",
        "@zed-industries",
        "codex-acp",
        "node_modules",
        "@zed-industries",
        "codex-acp-*",
        "bin",
        "codex-acp*"
      ),
      join_paths(root, "_npx", "*", "node_modules", "@zed-industries", "codex-acp-*", "bin", "codex-acp*"),
    })
  end

  local matches = {}
  for _, pattern in ipairs(patterns) do
    vim.list_extend(matches, vim.fn.glob(pattern, false, true))
  end

  return latest_executable(matches)
end

local function windows_package_name()
  local machine = normalize_path((uv.os_uname().machine or ""):lower())

  if machine == "arm64" or machine == "aarch64" then
    return "@zed-industries/codex-acp-win32-arm64"
  end

  return "@zed-industries/codex-acp-win32-x64"
end

local function npx_fallback()
  local npx = executable_on_path(is_windows() and { "npx.cmd", "npx", "npx.exe" } or { "npx" })
  if not npx then
    return nil
  end

  local argv = {
    npx,
    "--yes",
    "--package",
    "@zed-industries/codex-acp",
  }

  if is_windows() then
    table.insert(argv, "--package")
    table.insert(argv, windows_package_name())
  end

  table.insert(argv, "codex-acp")

  return argv
end

local function build_resolution(argv, source)
  if not argv or #argv == 0 then
    return nil
  end

  local args = {}
  for i = 2, #argv do
    table.insert(args, argv[i])
  end

  return {
    source = source,
    command = argv[1],
    args = args,
    argv = argv,
  }
end

function M.resolve()
  if resolved_command then
    return vim.deepcopy(resolved_command)
  end

  local cached = cached_codex_acp()
  if cached then
    resolved_command = build_resolution({ cached }, "cache")
    return vim.deepcopy(resolved_command)
  end

  local command = executable_on_path(is_windows() and { "codex-acp", "codex-acp.cmd", "codex-acp.exe" } or {
    "codex-acp",
  })
  if command then
    resolved_command = build_resolution({ command }, "path")
    return vim.deepcopy(resolved_command)
  end

  local fallback = npx_fallback()
  if fallback then
    resolved_command = build_resolution(fallback, "npx")
    return vim.deepcopy(resolved_command)
  end

  return nil
end

function M.command()
  local resolved = M.resolve()
  return resolved and resolved.command or nil
end

function M.args(extra_args)
  local resolved = M.resolve()
  if not resolved then
    return nil
  end

  local args = copy_list(resolved.args)
  for _, arg in ipairs(extra_args or {}) do
    table.insert(args, arg)
  end

  return args
end

function M.argv(extra_args)
  local resolved = M.resolve()
  if not resolved then
    return nil
  end

  local argv = copy_list(resolved.argv)
  for _, arg in ipairs(extra_args or {}) do
    table.insert(argv, arg)
  end

  return argv
end

return M

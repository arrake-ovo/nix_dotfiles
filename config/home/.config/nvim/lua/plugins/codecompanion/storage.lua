local settings = require("plugins.codecompanion.settings")
local path = require("plugins.codecompanion.path")

local uv = vim.uv or vim.loop

local M = {}

local function copy_file_if_missing(src, dst)
  if not uv.fs_stat(src) or uv.fs_stat(dst) then
    return
  end

  path.ensure_dir(vim.fn.fnamemodify(dst, ":h"))

  local ok, err = pcall(uv.fs_copyfile, src, dst)
  if not ok then
    vim.notify(
      "CodeCompanion failed to bootstrap isolated state from " .. src .. ": " .. tostring(err),
      vim.log.levels.WARN
    )
  end
end

local function ensure_symlink(src, dst)
  if not uv.fs_stat(src) then
    return
  end

  path.ensure_dir(vim.fn.fnamemodify(dst, ":h"))

  local existing = uv.fs_lstat(dst)
  if existing then
    if existing.type == "link" then
      local current_target = uv.fs_readlink(dst)
      if current_target == src then
        return
      end
    end

    local ok_unlink, unlink_err = pcall(uv.fs_unlink, dst)
    if not ok_unlink then
      vim.notify(
        "CodeCompanion failed to replace " .. dst .. " with a symlink: " .. tostring(unlink_err),
        vim.log.levels.WARN
      )
      return
    end
  end

  local ok_link, link_err = pcall(uv.fs_symlink, src, dst)
  if not ok_link then
    vim.notify(
      "CodeCompanion failed to link " .. dst .. " -> " .. src .. ": " .. tostring(link_err),
      vim.log.levels.WARN
    )
  end
end

local function copy_tree_if_missing(src, dst)
  if not uv.fs_stat(src) then
    return
  end

  path.ensure_dir(dst)

  for name, kind in vim.fs.dir(src) do
    local src_path = path.join_paths(src, name)
    local dst_path = path.join_paths(dst, name)

    if kind == "directory" then
      copy_tree_if_missing(src_path, dst_path)
    elseif kind == "file" then
      copy_file_if_missing(src_path, dst_path)
    end
  end
end

function M.codecompanion_root()
  -- 迁移到 nix 管理后，config 目录是项目软链接（只读语义），
  -- 运行时数据改放标准 data 目录（~/.local/share/nvim/codecompanion）
  return path.join_paths(vim.fn.stdpath("data"), "codecompanion")
end

function M.codecompanion_token_path()
  if settings.isolate_from_global then
    return path.join_paths(M.codecompanion_root(), "tokens")
  end

  return vim.fn.expand("~/.config")
end

function M.codex_home()
  if settings.isolate_from_global then
    return path.join_paths(M.codecompanion_root(), "codex")
  end

  if vim.env.CODEX_HOME and vim.env.CODEX_HOME ~= "" then
    return vim.env.CODEX_HOME
  end

  return path.join_paths(vim.env.HOME or "", ".codex")
end

function M.bootstrap_isolated_state()
  if not settings.isolate_from_global then
    return
  end

  local home = vim.env.HOME or ""
  local token_path = M.codecompanion_token_path()
  local codex_path = M.codex_home()

  path.ensure_dir(M.codecompanion_root())
  path.ensure_dir(token_path)
  path.ensure_dir(codex_path)
  path.ensure_dir(path.join_paths(codex_path, "sessions"))
  path.ensure_dir(path.join_paths(codex_path, "archived_sessions"))

  -- Reuse existing sign-in state on first boot without pulling over global chat history.
  copy_tree_if_missing(path.join_paths(home, ".config", "github-copilot"), path.join_paths(token_path, "github-copilot"))
  ensure_symlink(path.join_paths(home, ".codex", "auth.json"), path.join_paths(codex_path, "auth.json"))

  for _, file in ipairs({
    "config.toml",
    "config.json",
    "AGENTS.md",
    "instructions.md",
  }) do
    copy_file_if_missing(path.join_paths(home, ".codex", file), path.join_paths(codex_path, file))
  end

  copy_tree_if_missing(path.join_paths(home, ".codex", "rules"), path.join_paths(codex_path, "rules"))

  vim.env.CODECOMPANION_TOKEN_PATH = token_path
  vim.env.CODEX_HOME = codex_path
end

return M

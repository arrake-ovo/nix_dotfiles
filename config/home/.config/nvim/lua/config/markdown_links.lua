local M = {}

local markdown_extensions = {
  ".md",
  ".markdown",
  ".mdx",
}

local function trim(text)
  return vim.trim(text or "")
end

local function decode_target(target)
  target = target or ""
  target = target:gsub("\\ ", " ")
  target = target:gsub("\\([()])", "%1")
  return (target:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end))
end

local function is_remote_link(target)
  return (target:match("^%a[%w+.-]*://") and not target:match("^file://"))
    or target:match("^mailto:")
    or target:match("^tel:")
end

local function is_markdown_file(path)
  local lower = path:lower()
  for _, ext in ipairs(markdown_extensions) do
    if lower:sub(-#ext) == ext then
      return true
    end
  end
  return false
end

local function looks_like_local_target(target)
  return target:match("^#")
    or target:match("^/")
    or target:match("^%.")
    or target:match("%.md$")
    or target:match("%.markdown$")
    or target:match("%.mdx$")
end

local function normalize_anchor(text)
  local anchor = trim(decode_target(text))
  anchor = anchor:gsub("^#+", "")
  anchor = anchor:gsub("`", "")
  anchor = anchor:gsub("[%*_~]", "")
  anchor = anchor:gsub("%s+", "-")
  anchor = anchor:gsub("[!\"#$%%&'()*+,./:;<=>?@%[%]\\^`{|}~]", "")
  anchor = anchor:gsub("%-+", "-")
  anchor = anchor:gsub("^%-+", "")
  anchor = anchor:gsub("%-+$", "")
  return anchor:lower()
end

local function jump_to_anchor(anchor)
  local target = normalize_anchor(anchor)
  if target == "" then
    return false
  end

  local seen = {}
  for linenr, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    local heading = line:match("^%s*#+%s+(.+)$")
    if heading then
      local slug = normalize_anchor(heading)
      local count = seen[slug] or 0
      seen[slug] = count + 1

      local candidate = slug
      if count > 0 then
        candidate = ("%s-%d"):format(slug, count)
      end

      if candidate == target then
        vim.api.nvim_win_set_cursor(0, { linenr, 0 })
        vim.cmd("normal! zz")
        return true
      end
    end
  end

  return false
end

local function extract_inline_destination(destination)
  destination = trim(destination)

  local wrapped = destination:match("^<(.+)>")
  if wrapped then
    return wrapped
  end

  local bare = destination:match("^(.-)%s+[\"'].*$")
  if bare then
    return bare
  end

  bare = destination:match("^(.-)%s+%b()$")
  if bare then
    return bare
  end

  return destination
end

local function find_inline_link(line, col)
  local from = 1

  while true do
    local start_col, end_col = line:find("%b[]%b()", from)
    if not start_col then
      return nil
    end

    if line:sub(start_col - 1, start_col - 1) ~= "!" and col >= start_col and col <= end_col then
      local segment = line:sub(start_col, end_col)
      local destination = segment:match("^%b[]%((.*)%)$")
      if destination then
        return extract_inline_destination(destination)
      end
    end

    from = start_col + 1
  end
end

local function find_wiki_link(line, col)
  local from = 1

  while true do
    local start_col, end_col = line:find("%[%[[^%]]-%]%]", from)
    if not start_col then
      return nil
    end

    if col >= start_col and col <= end_col then
      local target = line:sub(start_col + 2, end_col - 2)
      target = trim((target:match("^[^|]+") or target))
      if target ~= "" then
        return target
      end
    end

    from = start_col + 1
  end
end

local function find_angle_link(line, col)
  local from = 1

  while true do
    local start_col, end_col = line:find("<[^>]+>", from)
    if not start_col then
      return nil
    end

    if col >= start_col and col <= end_col then
      local target = line:sub(start_col + 1, end_col - 1)
      if looks_like_local_target(target) or is_remote_link(target) then
        return target
      end
    end

    from = start_col + 1
  end
end

local function target_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1

  return find_inline_link(line, col) or find_wiki_link(line, col) or find_angle_link(line, col)
end

local function split_target(target)
  if target:match("^file://") then
    local path, fragment = target:match("^(file://.-)#(.*)$")
    if path then
      return vim.uri_to_fname(path), decode_target(fragment)
    end
    return vim.uri_to_fname(target), nil
  end

  local path, anchor = target:match("^(.-)#(.*)$")
  if path then
    return decode_target(path), decode_target(anchor)
  end

  return decode_target(target), nil
end

local function resolve_local_path(path)
  local current_file = vim.api.nvim_buf_get_name(0)
  local base_dir = current_file ~= "" and vim.fs.dirname(current_file) or vim.uv.cwd()
  local candidates = {}
  local seen = {}

  local function add(candidate)
    if not candidate or candidate == "" then
      return
    end

    local normalized = vim.fs.normalize(candidate)
    if seen[normalized] then
      return
    end

    seen[normalized] = true
    table.insert(candidates, normalized)
  end

  if path == "" then
    add(current_file)
  else
    if path:sub(1, 1) == "~" then
      path = vim.fn.expand(path)
    end

    if path:sub(1, 1) == "/" then
      add(path)
    else
      add(vim.fs.joinpath(base_dir, path))
    end
  end

  for i = 1, #candidates do
    local candidate = candidates[i]
    if not is_markdown_file(candidate) then
      for _, ext in ipairs(markdown_extensions) do
        add(candidate .. ext)
      end
      add(vim.fs.joinpath(candidate, "index.md"))
    end
  end

  for _, candidate in ipairs(candidates) do
    local stat = vim.uv.fs_stat(candidate)
    if stat and stat.type == "file" then
      return candidate
    end
  end

  return nil
end

local function open_with_system_app(target)
  local _, err = vim.ui.open(target)
  if err then
    vim.notify(("打开链接失败: %s"):format(err), vim.log.levels.ERROR)
  end
end

function M.open_under_cursor()
  local target = target_under_cursor()
  if not target then
    vim.notify("光标下没有可打开的 Markdown 链接", vim.log.levels.INFO)
    return
  end

  if is_remote_link(target) then
    open_with_system_app(target)
    return
  end

  local path, anchor = split_target(target)

  if path == "" then
    if anchor and jump_to_anchor(anchor) then
      return
    end

    vim.notify(("没有找到标题锚点: #%s"):format(anchor or ""), vim.log.levels.WARN)
    return
  end

  local resolved = resolve_local_path(path)
  if not resolved then
    vim.notify(("找不到本地链接目标: %s"):format(target), vim.log.levels.WARN)
    return
  end

  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file == "" or vim.fs.normalize(current_file) ~= resolved then
    vim.cmd("badd " .. vim.fn.fnameescape(resolved))
  end

  if anchor and anchor ~= "" then
    if is_markdown_file(resolved) and jump_to_anchor(anchor) then
      return
    end

    vim.notify(("没有找到标题锚点: #%s"):format(anchor), vim.log.levels.WARN)
  end
end

return M

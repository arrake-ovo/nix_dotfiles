local Pos = require("flash.search.pos")

local M = {}

local function is_ident_char(c)
  if not c then
    return false
  end
  return c:match("[a-zA-Z0-9_]") ~= nil
end

---Find all chain members on current line
function M.get_chain_members(win, cursor_pos)
  local buf = vim.api.nvim_win_get_buf(win)
  local row = cursor_pos[1]
  local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]

  if not line or line == "" then
    return {}
  end

  local line_len = #line

  local function char_at(idx)
    if idx < 0 or idx >= line_len then
      return nil
    end
    return line:sub(idx + 1, idx + 1)
  end

  -- Parse identifier and return {start, end}
  local function parse_identifier(start)
    local idx = start
    while idx < line_len and is_ident_char(char_at(idx)) do
      idx = idx + 1
    end
    if idx > start then
      return start, idx - 1
    end
    return nil
  end

  -- Parse chain starting at position
  local function parse_chain(start_idx)
    local members = {}
    local idx = start_idx
    local first = true

    while idx < line_len do
      local sep_len = 0

      if not first then
        local c = char_at(idx)
        if c == "." or c == ":" then
          sep_len = 1
          idx = idx + 1
        else
          break
        end
      end

      if not is_ident_char(char_at(idx)) then
        break
      end

      local ok, member_end = parse_identifier(idx)
      if not ok then
        break
      end
      local member_start = idx

      local outer_start = first and member_start or member_start - sep_len

      table.insert(members, {
        inner = {
          pos = Pos({ row, member_start }),
          end_pos = Pos({ row, member_end }),
        },
        outer = {
          pos = Pos({ row, outer_start }),
          end_pos = Pos({ row, member_end }),
        },
      })

      idx = member_end + 1
      first = false
    end

    return members, idx
  end

  -- Scan line for all chains
  local result = {}
  local idx = 0

  while idx < line_len do
    if is_ident_char(char_at(idx)) then
      local members, next_idx = parse_chain(idx)
      for _, m in ipairs(members) do
        table.insert(result, m)
      end
      idx = next_idx
    else
      idx = idx + 1
    end
  end

  return result
end

function M.jump(inner)
  local win = vim.api.nvim_get_current_win()
  local cursor_pos = Pos()

  local members = M.get_chain_members(win, cursor_pos)

  if #members == 0 then
    vim.notify("No chain members found", vim.log.levels.INFO)
    return
  end

  require("flash").jump({
    matcher = function(win2, state)
      local labels = state:labels()
      local ms = M.get_chain_members(win2, state.pos)
      local matches = {}
      for _, m in ipairs(ms) do
        local p = inner and m.inner.pos or m.outer.pos
        local ep = inner and m.inner.end_pos or m.outer.end_pos
        table.insert(matches, {
          pos = p,
          end_pos = ep,
          label = table.remove(labels, 1),
          win = win2,
        })
      end
      return matches
    end,
    jump = { pos = "range", autojump = true },
    search = { max_length = 0, multi_window = false },
    label = { before = true, after = false, style = "inline" },
    highlight = { backdrop = false, matches = false },
  })
end

return M
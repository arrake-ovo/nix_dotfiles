local M = {}

M.motions = {
  left = "n",
  up = "u",
  down = "e",
  right = "i",
}

local function with_desc(desc, opts)
  return vim.tbl_extend("force", { silent = true, desc = desc }, opts or {})
end

local function map(mode, lhs, rhs, desc, opts)
  vim.keymap.set(mode, lhs, rhs, with_desc(desc, opts))
end

function M.wk_desc(label)
  return label
end

function M.apply_list_keys(keys, opts)
  opts = opts or {}
  local motions = M.motions
  local merged = vim.tbl_deep_extend("force", {}, keys or {})

  local function assign(lhs, rhs)
    if rhs == false then
      merged[lhs] = nil
    elseif rhs ~= nil then
      merged[lhs] = rhs
    end
  end

  assign(motions.up, opts.up or "list_up")
  assign(motions.down, opts.down or "list_down")
  assign(motions.left, opts.left or "cancel")
  assign(motions.right, opts.right or "confirm")

  if opts.focus then
    assign("k", opts.focus)
  end
  if opts.ctrl_up then
    assign("<C-u>", opts.ctrl_up)
  end
  if opts.ctrl_down then
    assign("<C-e>", opts.ctrl_down)
  end
  if opts.ctrl_left then
    assign("<C-n>", opts.ctrl_left)
  end

  return merged
end

function M.apply_buffer_keys(bufnr, spec)
  spec = spec or {}

  local function buf_map(lhs, rhs, desc)
    if rhs == nil then
      return
    end
    vim.keymap.set("n", lhs, rhs, with_desc(desc, {
      buffer = bufnr,
      nowait = true,
    }))
  end

  if spec.up then
    buf_map(M.motions.up, spec.up, M.wk_desc("Up"))
  end
  if spec.down then
    buf_map(M.motions.down, spec.down, M.wk_desc("Down"))
  end
  if spec.left then
    buf_map(M.motions.left, spec.left, M.wk_desc("Left"))
  end
  if spec.right then
    buf_map(M.motions.right, spec.right, M.wk_desc("Right"))
  end
end

function M.setup()
  local motions = M.motions
  local up_expr = "v:count == 0 ? 'gk' : 'k'"
  local down_expr = "v:count == 0 ? 'gj' : 'j'"

  map({ "n", "x", "o" }, motions.left, "h", M.wk_desc("Move Left"))
  map({ "n", "x", "o" }, motions.right, "l", M.wk_desc("Move Right"))
  map({ "n", "x" }, motions.up, up_expr, M.wk_desc("Move Up"), { expr = true })
  map({ "n", "x" }, motions.down, down_expr, M.wk_desc("Move Down"), { expr = true })
  map("o", motions.up, "k", M.wk_desc("Move Up"))
  map("o", motions.down, "j", M.wk_desc("Move Down"))

  map({ "n", "x", "o" }, string.upper(motions.up), "5k", "Move Up 5 Lines")
  map({ "n", "x", "o" }, string.upper(motions.down), "5j", "Move Down 5 Lines")
  map({ "n", "x", "o" }, "W", "5w", "Move Forward 5 Words")
  map({ "n", "x", "o" }, "B", "5b", "Move Backward 5 Words")
  map({ "n", "x", "o" }, "h", "e", "End of Word")
  map({ "n", "x", "o" }, "N", "^", "Line Start")
  map({ "n", "x", "o" }, "I", "g_", "Line End")
  map({ "n", "x", "o" }, "H", "0", "Absolute Line Start")
  map({ "n", "x", "o" }, "M", "$", "Absolute Line End")

  map("n", "<leader>w" .. motions.up, "<C-w>k", "Window Up", { remap = true })
  map("n", "<leader>w" .. motions.down, "<C-w>j", "Window Down", { remap = true })
  map("n", "<leader>w" .. motions.left, "<C-w>h", "Window Left", { remap = true })
  map("n", "<leader>w" .. motions.right, "<C-w>l", "Window Right", { remap = true })

  for _, lhs in ipairs({ "<C-h>", "<C-j>", "<C-k>", "<C-l>" }) do
    pcall(vim.keymap.del, "n", lhs)
  end

  map("n", "<C-" .. motions.left .. ">", "<C-w>h", "Window Left", { remap = true })
  map("n", "<C-" .. motions.up .. ">", "<C-w>k", "Window Up", { remap = true })
  map("n", "<C-" .. motions.down .. ">", "<C-w>j", "Window Down", { remap = true })
  map("n", "<C-" .. motions.right .. ">", "<C-w>l", "Window Right", { remap = true })

  local filetypes = {
    lazy = { up = "k", down = "j", left = "h", right = "l" },
    mason = { up = "k", down = "j", left = "h", right = "l" },
    qf = { up = "k", down = "j" },
    ["dapui_scopes"] = { up = "k", down = "j" },
    ["dapui_breakpoints"] = { up = "k", down = "j" },
    ["dapui_stacks"] = { up = "k", down = "j" },
    ["dapui_watches"] = { up = "k", down = "j" },
    ["grug-far-history"] = { up = "k", down = "j" },
    ["grug-far-help"] = { up = "k", down = "j" },
  }

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("colemak_list_buffers", { clear = true }),
    pattern = vim.tbl_keys(filetypes),
    callback = function(args)
      M.apply_buffer_keys(args.buf, filetypes[args.match])
    end,
  })
end

return M

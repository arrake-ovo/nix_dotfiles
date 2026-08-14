local function focus_noice_lsp_docs()
  local ok, docs = pcall(require, "noice.lsp.docs")
  if not ok then
    return false
  end

  for _, kind in ipairs({ "hover", "signature" }) do
    local message = docs._messages and docs._messages[kind]
    if message and message.focus and message:focus() then
      return true
    end
  end

  return false
end

return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("colemak_lsp_keys", { clear = true }),
        callback = function(args)
          vim.keymap.set("n", "K", function()
            if not focus_noice_lsp_docs() then
              vim.lsp.buf.hover()
            end
          end, {
            buffer = args.buf,
            desc = "Hover / Focus Hover",
          })
        end,
      })
    end,
  },
}

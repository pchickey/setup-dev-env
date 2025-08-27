

local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set(
  "n", 
  "<leader>a", 
  function()
    vim.cmd.RustLsp('codeAction')
  end,
  { silent = true, buffer = bufnr }
)

vim.keymap.set(
  "n", 
  "<leader>k", 
  function()
    vim.cmd.RustLsp('hover')
  end,
  { silent = true, buffer = bufnr }
)

vim.keymap.set(
  "n", 
  "<leader>d", 
  function()
    vim.lsp.buf.definition()
  end,
  { silent = true, buffer = bufnr }
)

vim.keymap.set(
  "n", 
  "<leader>x", 
  function()
    vim.lsp.buf.references()
  end,
  { silent = true, buffer = bufnr }
)

vim.keymap.set(
  "n", 
  "<leader>r", 
  function()
    vim.lsp.buf.rename()
  end,
  { silent = true, buffer = bufnr }
)

vim.keymap.set(
  "n", 
  "<leader>i", 
  function()
    vim.cmd.RustLsp({'renderDiagnostic', 'current'})
  end,
  { silent = true, buffer = bufnr }
)


vim.cmd('set tw=78')

   --Enable completion triggered by <c-x><c-o>
--[[
  opt ('omnifunc', 'v:lua.vim.lsp.omnifunc')

  mapcmd('<leader>k', 'vim.lsp.buf.hover()')
  mapcmd('<leader>d', 'vim.lsp.buf.definition()')
  mapcmd('<leader>x', 'vim.lsp.buf.references()')
  mapcmd('<leader>r', 'vim.lsp.buf.rename()')
  mapcmd('<leader>a', 'vim.lsp.buf.code_action()')
  mapcmd('<leader>i', 'vim.diagnostic.open_float()')
]]


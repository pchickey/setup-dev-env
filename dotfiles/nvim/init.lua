local cmd = vim.cmd
local fn = vim.fn
local g = vim.g

local function opt(scope, key, value)
  local scopes = {o = vim.o, b = vim.bo, w = vim.wo}
  scopes[scope][key] = value
  if scope ~= 'o' then scopes['o'][key] = value end
end
local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

cmd 'colorscheme default'

local indent = 4
opt('o', 'showmatch', true) -- show matching brackets
opt('o', 'mouse', 'a')           -- mouse support in all modes
opt('o', 'incsearch', true)         -- incremental search
opt('o', 'hlsearch', true)          -- highlight search results
opt('o', 'tabstop', indent)         -- tabs are 4 characters
opt('o', 'softtabstop', indent)-- see multiple spaces as tabstops, for backspacing
opt('o', 'expandtab', true)         -- expand tabs to whitespace
opt('o', 'shiftwidth', indent)      -- expand them 4 wide
opt('o', 'autoindent', true)        -- indent new line same amount as current
opt('o', 'textwidth', 78)      --format paragraphs to 78 cols with :gq
opt('o', 'formatoptions', 'cqj') -- no t: dont auto format code, c: auto format comments, q: :gq works, j: remove comment leader when joining lines

cmd 'filetype plugin indent on'-- auto-indent depending on file type
cmd 'syntax on'             -- syntax highlighting on
cmd 'set hidden'            -- allow plugins to modify mult buffers (LC rename)
cmd 'set title'             -- set window title

g['mapleader'] = ';'
-- clear highlighting with ;;
map('n', '<leader><leader>', '<cmd>noh<CR>') -- clear highlights

-- Highlight trailing spaces
opt('w', 'list', true)
opt('w', 'listchars', 'trail:·,tab:»·,nbsp:+')


cmd 'packadd paq-nvim' -- load package manager
local paq = require('paq-nvim').paq -- alias
paq {'savq/paq-nvim', opt = true } -- paq manages itself

paq {'tpope/vim-markdown'}
paq {'tpope/vim-fugitive'}
paq {'tpope/vim-rhubarb'}
paq {'fidian/hexmode'}
paq {'rhysd/vim-wasm'}
paq {'leafgarland/typescript-vim'}
paq {'jremmen/vim-ripgrep'}

paq {'rust-lang/rust.vim'}
g['rustfmt_autosave'] = 1

paq {'neovim/nvim-lspconfig'}

local nvim_lsp = require('lspconfig')
local on_attach = function(client, bufnr)
  local opts = {noremap = true, silent = true}
  local function mapcmd(lhs, cmd) vim.api.nvim_buf_set_keymap(bufnr, 'n', lhs, "<cmd>lua " .. cmd .. "<CR>", opts) end
  local function opt(...) vim.api.nvim_buf_set_option(bufnr, ...) end

   --Enable completion triggered by <c-x><c-o>
  opt ('omnifunc', 'v:lua.vim.lsp.omnifunc')

  mapcmd('<leader>k', 'vim.lsp.buf.hover()')
  mapcmd('<leader>d', 'vim.lsp.buf.definition()')
  mapcmd('<leader>x', 'vim.lsp.buf.references()')
  mapcmd('<leader>r', 'vim.lsp.buf.rename()')
  mapcmd('<leader>i', 'vim.lsp.diagnostic.show_line_diagnostics()')

end

nvim_lsp.rust_analyzer.setup{ on_attach = on_attach }


paq {'junegunn/fzf', run = fn['fzf#install']}
paq {'junegunn/fzf.vim'}
paq {'ojroques/nvim-lspfuzzy'}

require('lspfuzzy').setup{}

paq {'hoob3rt/lualine.nvim'}
paq {'kyazdani42/nvim-web-devicons'}
paq {'ryanoasis/vim-devicons'}

require('lualine').setup()

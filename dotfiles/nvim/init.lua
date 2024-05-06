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
cmd 'set nofixeol'          -- dont mess with eol

-- clear highlighting with ;;
map('n', '<leader><leader>', '<cmd>noh<CR>') -- clear highlights

-- Highlight trailing spaces
opt('w', 'list', true)
opt('w', 'listchars', 'trail:·,tab:»·,nbsp:+')


g['mapleader'] = ' '
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({

  { 'nvim-treesitter/nvim-treesitter', run = cmd('normal TSUpdate') },

  'tpope/vim-markdown',
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'fidian/hexmode',
  'rhysd/vim-wasm',
  'leafgarland/typescript-vim',
  'jremmen/vim-ripgrep',

  'rust-lang/rust.vim',

  {'junegunn/fzf', run = fn['fzf#install']},
  'junegunn/fzf.vim',
  'ojroques/nvim-lspfuzzy',

  { 'hoob3rt/lualine.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },
  'kyazdani42/nvim-web-devicons',
  'ryanoasis/vim-devicons',

  'neovim/nvim-lspconfig',
  'simrat39/rust-tools.nvim',

  'rebelot/kanagawa.nvim',
})
g['mapleader'] = ';'

g['rustfmt_autosave'] = 1
require('lspfuzzy').setup{}
require('lualine').setup()
require('kanagawa').setup { transparent = true }

require('nvim-treesitter.configs').setup {
    ensure_installed = { "bash", "c", "cpp", "javascript", "lua", "ruby", "rust", "typescript" },
    highlight = { enable = true }
}

cmd 'colorscheme kanagawa'

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
  mapcmd('<leader>a', 'vim.lsp.buf.code_action()')
  mapcmd('<leader>i', 'vim.diagnostic.open_float()')

end
nvim_lsp.rust_analyzer.setup({
    on_attach = on_attach,
    cmd = { "rustup", "run", "stable", "rust-analyzer" },
    settings = {
        ["rust-analyzer"] = {
            buildScripts = {
                enable = true
            },
            diagnostics = {
                disabled = { "inactive-code" }
            },
            procMacro = {
                enable = true
            }
        }
    }
})

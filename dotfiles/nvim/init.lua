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

  { 'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    config = function ()
        local configs = require("nvim-treesitter.configs")

        configs.setup({
            ensure_installed = { "bash", "c", "cpp", "javascript", "lua", "ruby", "rust", "typescript", "wit" },
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = true },  
        })
    end
  },

  'tpope/vim-markdown',
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'fidian/hexmode',
  'rhysd/vim-wasm',
  'leafgarland/typescript-vim',
  'jremmen/vim-ripgrep',

  'rust-lang/rust.vim',
  { 'mrcjkb/rustaceanvim', version = '^6', lazy = false },

  {'junegunn/fzf', run = fn['fzf#install']},
  'junegunn/fzf.vim',
  'ojroques/nvim-lspfuzzy',

  { 'hoob3rt/lualine.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },
  'kyazdani42/nvim-web-devicons',
  'ryanoasis/vim-devicons',

  'neovim/nvim-lspconfig',

  -- colorscheme:
  'rebelot/kanagawa.nvim',
})
g['mapleader'] = ';'

require('lspfuzzy').setup{}
require('lualine').setup()
require('kanagawa').setup { transparent = true }

cmd 'colorscheme kanagawa'

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp", { clear = true }),
  callback = function(args)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = args.buf,
      callback = function()
        vim.lsp.buf.format {async = false, id = args.data.client_id }
      end,
    })
  end
})

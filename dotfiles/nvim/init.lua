local cmd = vim.cmd
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
opt('o', 'autoread', true)  -- auto-reload buffers changed on disk (e.g. by cargo fmt)

-- clear highlighting with ;;
map('n', '<leader><leader>', '<cmd>noh<CR>') -- clear highlights

-- Highlight trailing spaces
opt('w', 'list', true)
opt('w', 'listchars', 'trail:·,tab:»·,nbsp:+')


g['mapleader'] = ' '

-- Run post-install/update hooks that lazy.nvim used to run via `build`/`run`.
-- Must be registered before the first `vim.pack.add()` call so it also
-- fires for fresh installs.
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'fzf' and (kind == 'install' or kind == 'update') then
      vim.system({ ev.data.path .. '/install', '--bin' })
    end
  end,
})

vim.pack.add({
  -- 'main' branch: the only branch supported on Nvim >= 0.12.
  'https://github.com/nvim-treesitter/nvim-treesitter',

  'https://github.com/tpope/vim-markdown',
  'https://github.com/tpope/vim-fugitive',
  'https://github.com/tpope/vim-rhubarb',
  'https://github.com/fidian/hexmode',
  'https://github.com/rhysd/vim-wasm',
  'https://github.com/leafgarland/typescript-vim',
  'https://github.com/jremmen/vim-ripgrep',

  { src = 'https://github.com/mrcjkb/rustaceanvim', version = vim.version.range('6') },

  'https://github.com/junegunn/fzf',
  'https://github.com/junegunn/fzf.vim',
  'https://github.com/ojroques/nvim-lspfuzzy',

  'https://github.com/hoob3rt/lualine.nvim',
  'https://github.com/kyazdani42/nvim-web-devicons',
  'https://github.com/ryanoasis/vim-devicons',

  'https://github.com/neovim/nvim-lspconfig',

  -- colorscheme:
  'https://github.com/rebelot/kanagawa.nvim',
}, { load = true })

-- nvim-treesitter's `main` branch dropped the old `nvim-treesitter.configs`
-- setup API; parsers are installed explicitly and features (highlight,
-- indent) are enabled per-filetype via autocommands instead.
local ts_langs = { "bash", "c", "cpp", "javascript", "lua", "ruby", "rust", "typescript", "wit" }
require('nvim-treesitter').install(ts_langs)
vim.api.nvim_create_autocmd('FileType', {
  pattern = ts_langs,
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
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
        -- vim.lsp.buf.format {async = false, id = args.data.client_id }
      end,
    })
  end
})

vim.g.rustaceanvim = {
  server = {
    default_settings = {
      ['rust-analyzer'] = {
        cargo = { 
          allFeatures = true,
          loadOutDirsFromCheck = true,
          runBuildScripts = true,
        },
        checkOnSave = true,
        check = { 
          allFeatures = true,
          command = 'clippy',
          extraArgs = { '--no-deps' },
        },
        procMacro = { 
          enable = true,
        },
      },
    },
  },
}

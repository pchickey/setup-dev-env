
set nocompatible            " disable compat with vi
set showmatch               " show matching brackets
set mouse=a                 " mouse support in all modes
set incsearch               " incremental search
set hlsearch                " highlight search results
set tabstop=4               " tabs are 4 characters
set softtabstop=4           " see multiple spaces as tabstops, for backspacing
set expandtab               " expand tabs to whitespace
set shiftwidth=4            " expand them 4 wide
set autoindent              " indent new line same amount as current
" set cc=80                   " 80 column border
" au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1) " highlight past 80
filetype plugin indent on   " auto-indent depending on file type
syntax on                   " syntax highlighting on
set hidden                  " allow plugins to modify mult buffers (LC rename)
set title                   " set window title

colorscheme default

let g:mapleader = ';'
" clear highlighting with ;;
nnoremap <Leader><Leader> :noh<Enter>

" Highlight trailing spaces.
set list lcs=tab:>-,trail:.

" install plugin manager
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


call plug#begin('~/.vim/plugged')

" fzf plugin is installed via git
Plug '~/.fzf'

" language client for RLS integration
Plug '~/src/LanguageClient-neovim'
Plug 'tpope/vim-markdown'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'rust-lang/rust.vim'
Plug 'fidian/hexmode'
Plug 'rhysd/vim-wasm'
Plug 'leafgarland/typescript-vim'
Plug 'jremmen/vim-ripgrep'

Plug 'itchyny/lightline.vim'

call plug#end()

let g:LanguageClient_autoStart=1
let g:LanguageClient_serverCommands = {
    \ 'rust': ['rustup', 'run', 'stable', 'rls'], 
    \  }
nnoremap <silent> <Leader>k :call LanguageClient#textDocument_hover()<Enter>
nnoremap <silent> <Leader>d :call LanguageClient#textDocument_definition()<Enter>
nnoremap <silent> <Leader>t :call LanguageClient#textDocument_typeDefinition()<Enter>
nnoremap <silent> <Leader>r :call LanguageClient#textDocument_rename()<Enter>
nnoremap <silent> <Leader>x :call LanguageClient#textDocument_references()<Enter>
nnoremap <silent> <Leader>c :call LanguageClient#textDocument_completion()<Enter>
nnoremap <silent> <Leader>h :call LanguageClient#textDocument_hover()<Enter>
nnoremap <silent> <Leader>s :call LanguageClient#textDocument_documentSymbol()<Enter>
nnoremap <silent> <Leader>m :call LanguageClient_contextMenu()<Enter>

let g:rustfmt_autosave=1

let g:lightline = {
      \ 'component': {
      \   'readonly': '%{&readonly?"READ ONLY":""}'
      \ },
      \ 'active': {
      \   'left': [ ['mode', 'paste'],
      \             [ 'fugitive', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'LightLineFugitive',
      \ },
      \ }
function! LightLineFugitive()
    return exists('*FugitiveStatusline') ? FugitiveStatusline() : ''
endfunction


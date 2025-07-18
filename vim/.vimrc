" ========== Plugin Setup ==========
call plug#begin('~/.vim/plugged')

" File navigation
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" Statusline
Plug 'vim-airline/vim-airline'

" Git integration
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Markdown, TOC & Linting
Plug 'preservim/vim-markdown'
Plug 'godlygeek/tabular'
Plug 'mzlogin/vim-markdown-toc'
" Plug 'DavidAnson/vim-markdownlint'

" Go development
Plug 'govim/govim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'yami-beta/asyncomplete-omni.vim'

" Python development
Plug 'vim-python/python-syntax'
Plug 'psf/black', { 'branch': 'main' }

" Linting, formatting, diagnostics
Plug 'dense-analysis/ale'

" Clang formatting
Plug 'rhysd/vim-clang-format'

" YAML
Plug 'stephpy/vim-yaml'

" Colorscheme
Plug 'aonemd/quietlight.vim'

call plug#end()

" ========== General Settings ==========
syntax on

let mapleader = ","

set number
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set wrap
set linebreak
set cursorline
set hidden
set termguicolors
set nocompatible
set background=light
set nobackup
set nowritebackup
set noswapfile
set autoread
set updatetime=500
set balloondelay=250
set signcolumn=yes
set backspace=2
" https://github.com/govim/govim/wiki/vimrc-tips#-fix-why-does-vim-flicker-when-i-enter-normal-mode-leave-exit-insert-mode
set timeoutlen=1000 ttimeoutlen=0
set showcmd

set mouse=a
set ttymouse=sgr

filetype off
filetype indent on
filetype plugin on

colorscheme quietlight

" ========== Editing Behavior ==========
set clipboard=unnamedplus
set incsearch
set hlsearch
set ignorecase
set smartcase

" ========== Filetype Specific ==========
autocmd FileType go setlocal tabstop=4 shiftwidth=4
autocmd FileType python setlocal tabstop=4 shiftwidth=4
autocmd FileType markdown setlocal wrap linebreak nolist

" ========== Autoformat ==========
let g:ale_fix_on_save = 1
let g:ale_linters_explicit = 1
let g:ale_fixers = {
\   'python': ['black'],
\   'javascript': ['prettier'],
\   'markdown': ['prettier'],
\   'yaml': ['prettier'],
\   'cpp': ['clang-format'],
\}

" ========== Autocompletion ==========

" enabled only for *.go files

function! Omni()
    call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options({
         \ 'name': 'omni',
         \ 'whitelist': ['go'],
         \ 'completor': function('asyncomplete#sources#omni#completor')
         \  }))
endfunction

au VimEnter * :call Omni()

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? "\<C-y>" : "\<cr>"

" ========== clang-format ==========
let g:clang_format#style_options = {
\ 'BasedOnStyle': 'file',
\ }

" ========== Markdown TOC ==========
let g:vmt_auto_update_on_save = 1

" ========== Git ==========
nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gc :Gcommit<CR>
nnoremap <leader>gp :Gpush<CR>

" ========== FZF ==========
" nnoremap <C-p> :Files<CR>
" nnoremap <C-f> :Rg<CR>

" ========== NERDTree ==========
nnoremap <C-n> :NERDTreeToggle<CR>

" ========== Airline ==========
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#show_buffers = 1

" ========== Todo Highlights ==========
hi Todo guifg=White guibg=Orange
hi Note guifg=Red guibg=Yellow
hi Hack guifg=Black guibg=Green
hi Warn guifg=White guibg=Red
hi Kludge guifg=#ef42f5 guibg=Black

autocmd BufReadPost,BufNewFile * call matchadd('Todo', '\<TODO\>')
autocmd BufReadPost,BufNewFile * call matchadd('Note', '\<NOTE\>')
autocmd BufReadPost,BufNewFile * call matchadd('Hack', '\<HACK\>')
autocmd BufReadPost,BufNewFile * call matchadd('Warn', '\<WARN\>')
autocmd BufReadPost,BufNewFile * call matchadd('Kludge', '\<kludge\>')


" ========== Misc Settings ==========

" govim: show info for completion candidates in a popup menu
if has("patch-8.1.1904")
  set completeopt+=popup
  set completepopup=align:menu,border:off,highlight:Pmenu
endif

call govim#config#Set("FormatOnSave", "goimports-gofmt")

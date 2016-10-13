" Turn off compatibility mode
set nocp

" Infest by Pathogen
execute pathogen#infect()

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" allow unwritten buffers
set hidden
" keep 1000 lines of command line history
set history=1000
" use more levels of undo
set undolevels=1000
" disable swap file
set noswapfile
" line numbers
set number
" show the cursor position all the time
set ruler
" display incomplete commands
set showcmd
" do incremental searching
set incsearch
" wrap lines on 'word' boundaries
set linebreak
" don't let the cursor touch the edge of the viewport
set scrolloff=3
" Vertical splits use right half of screen
set splitright
"
set timeout
" Lower ^[ timeout
set timeoutlen=1000
" get rid of obnoxious '-' characters in folds
set fillchars=fold:\ ,
" use ~ to toggle case as an operator, not a motion
set tildeop
" new at bottom 
set splitbelow

" enable project specific vimrc
set exrc
if exists('&breakindent')
  set breakindent      " Indent wrapped lines up to the same level
endif

" Tab settings
set expandtab          " Expand tabs into spaces
set tabstop=4          " default spaces for a hard tab
set softtabstop=4      " default spaces for the soft tab
set shiftwidth=4       " for when <TAB> is pressed at the beginning of a line

" Set leadery key mapping
let mapleader="`"

" Mouse settings
if has('mouse')
  set mouse=a          " if mouse is available make use of it
endif

syntax on              " enable syntax
filetype plugin indent on
filetype plugin on

" Apperance/color scheme settings
"" (vim-colors-solarized)
if match($TERM, "xterm")!=-1
    set term=xterm-256color
    let g:solarized_termcolors=256
endif
set background=light
colorscheme solarized

"" vim-airline
let g:airline_powerline_fonts = 1
set laststatus=2
let g:airline_detect_paste=1
let g:airline#extensions#tabline#enabled = 1

"" nerdtree

"" vim-nerdtree-tabs
let g:nerdtree_tabs_open_on_console_startup = 1          " don't open NERDTree on startup
autocmd FileType nerdtree noremap <buffer> 1 <Nop>
autocmd FileType nerdtree noremap <buffer> 2 <Nop>


let mapleader = "`"

" Shortcuts
" pervious buffer
nmap 1 :bp<CR>
" next buffer
nmap 2 :bn<CR>

" omni completion
inoremap <C-n> <C-x><C-o>
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
autocmd CompleteDone * pclose

" go to next location
nnoremap <Leader><Up> <C-i>

" go to previous location
nnoremap <Leader><Down> <C-o>

" search currently selected word
noremap <Leader>f *
noremap <Leader>] *

" toggle project tree
noremap <Leader>a :NERDTreeTabsToggle<CR>

" focus window left
noremap <Leader><Left> <C-W><Left>
imap <Leader><Left> <Esc><C-W><Left>

" focus window right
noremap <Leader><Right> <C-W><Right>
imap <Leader><Right> <Esc><C-W><Right>


" Function key mappings:
" close current buffer without closing tab/window
nmap <F4> :Bclose<CR>

if &diff
    source ~/.vimrc-diff
endif

source ~/.vimrc-ide
" Enable security for project specific vimrc
set secure

" Functions

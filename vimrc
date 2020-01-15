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
" show options above commandline
set wildmenu


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

" enable syntax
syntax enable
filetype plugin indent on
filetype plugin on

" Apperance/color scheme settings
"" (vim-colors-solarized)
if match($TERM, "xterm")!=-1
    set term=xterm-256color
endif

let g:solarized_termcolors=256
let g:solarized_termtrans=1
set background=dark
colorscheme solarized

"" vim-airline
let g:airline_powerline_fonts = 1
set laststatus=2
let g:airline_detect_paste=1
let g:airline#extensions#tabline#enabled = 1

"" nerdtree

"" vim-nerdtree-tabs
let g:nerdtree_tabs_open_on_console_startup = 0
autocmd FileType nerdtree noremap <buffer> <F1> <Nop>
autocmd FileType nerdtree noremap <buffer> <F2> <Nop>
autocmd FileType nerdtree noremap <buffer> <F3> <Nop>
autocmd FileType nerdtree noremap <buffer> <F4> <Nop>

" Shortcuts
" =================== Functional Keys ==================
" pervious buffer
nmap <F1> :bp<CR>
" next buffer
nmap <F2> :bn<CR>
" build/make project
nmap <F3> :make<CR>
" close current buffer without closing tab/window
nmap <F4> :Bclose<CR>
" refresh indes
nmap <F5> :call RebuildIndex()<CR>

" =================== Leader based  ===================
" toggle project tree
noremap <Leader>a :NERDTreeTabsToggle<CR>
" jump forward
noremap <Leader><Right> <C-i>
" jump backward
noremap <Leader><Left> <C-o>
" find symbol definition
noremap <Leader><CR> <C-]>

" =================== Control key based ================
" navigate windows left/right
noremap <C-Left> <C-W><Left>
imap    <C-Left> <Esc>:w<CR><C-W><Left>
noremap <C-Right> <C-W><Right>
imap    <C-Right> <Esc>:w<CR><C-W><Right>

" file scrolling to the end/beginning
noremap <C-PageUp> 1G
noremap <C-PageDown> G

" omni completion
inoremap <C-n> <C-x><C-o>
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
autocmd CompleteDone * pclose

" =================== Slash prefix '\' based  ===========
" cscope find bindings
" - assignment
noremap \a :wa<CR>:cs find a <C-R>=expand("<cword>")<CR><CR>
" - where functions calling this function
noremap \c :wa<CR>:cs find c <C-R>=expand("<cword>")<CR><CR>
" - where function is called
noremap \d :wa<CR>:cs find d <C-R>=expand("<cword>")<CR><CR>
" - file
noremap \f :wa<CR>:cs find f <C-R>=expand("<cword>")<CR><CR>
" - definition
noremap \g :wa<CR>:cs find g <C-R>=expand("<cword>")<CR><CR>
" - including current file
noremap \i :wa<CR>:cs find i <C-R>=expand("%:t")<CR><CR>
" - symbol
noremap \s :wa<CR>:cs find s <C-R>=expand("<cword>")<CR><CR>
" - text/regular expression
noremap \e :wa<CR>:cs find e <C-R>=expand("<cword>")<CR>


if &diff
    nnoremap 1 [c
    nnoremap 2 ]c
    nnoremap q :qa<CR>
else
    source ~/.vimrc-ide
endif

" source ~/.vimrc-ide
" Enable security for project specific vimrc
set secure

" Functions

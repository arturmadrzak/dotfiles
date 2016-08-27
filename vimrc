" Turn off compatibility mode
set nocp

" Infest by Pathogen
execute pathogen#infect()

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=1000       " keep 1000 lines of command line history
set number             " line numbers
set ruler              " show the cursor position all the time
set showcmd            " display incomplete commands
set incsearch          " do incremental searching
set linebreak          " wrap lines on 'word' boundaries
set scrolloff=3        " don't let the cursor touch the edge of the viewport
set splitright         " Vertical splits use right half of screen
set timeoutlen=100     " Lower ^[ timeout
set fillchars=fold:\ , " get rid of obnoxious '-' characters in folds
set tildeop            " use ~ to toggle case as an operator, not a motion

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

"" nerdcommenter


" Indexer
set tags=./tags;
set completeopt=longest,menuone

" easytags
let g:easytags_async = 1
let g:easytags_syntax_keyword = 'always'
let g:easytags_file = './tags'
let g:easytags_on_cursorhold = 0

if has("cscope")
" look both cscope and ctags
  set cscopetag
" search cscope before ctags
  set csto=0                              
" if database exists, load it
  set nocscopeverbose
  if filereadable('cscope.out')
    cs add cscope.out                     
  endif
" make cscope be verbose
  set cscopeverbose

" find symbol references
  noremap <Leader>\ :wa<CR>:cs find s <C-R>=expand("<cword>")<CR><CR>

" find symbol definition
  noremap <Leader><CR> :wa<CR>:cs find g <C-R>=expand("<cword>")<CR><CR>

" find text occurences
  noremap <Leader>t :w<CR>:cs find t <C-R>=expand("<cword>")<CR><CR>

else
  echo "cscope is not present!"
endif


let mapleader = "`"

" Shortcuts
set timeout timeoutlen=1000

" omni completion
inoremap <C-n> <C-x><C-o>

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


if !&diff
" pervious buffer
  nmap 1 :bp<CR>
" next buffer
  nmap 2 :bn<CR>
endif


"" Diffmode
if &diff
    nnoremap 1 [c
    nnoremap 2 ]c
    nnoremap q :qa<CR>
endif


" Enable security for project specific vimrc
set secure

" Functions

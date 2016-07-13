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
set term=xterm-256color
let g:solarized_termcolors=256
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
autocmd FileType nerdtree noremap <buffer> <C-Left> <C-W><Left>
autocmd FileType nerdtree noremap <buffer> <C-Right> <C-W><Right>
autocmd FileType nerdtree noremap <buffer> 1 <Nop>
autocmd FileType nerdtree noremap <buffer> 2 <Nop>

"" nerdcommenter


" Indexer
set tags=./tags;
set completeopt=longest,menuone

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
  noremap <Leader><Down> :w<CR>:cs find s <C-R>=expand("<cword>")<CR><CR>
" find symbol definition
  noremap <Leader><CR> :w<CR>:cs find g <C-R>=expand("<cword>")<CR><CR>
" find functions calling this function
  noremap <Leader><Up> :w<CR>:cs find c <C-R>=expand("<cword>")<CR><CR>
else
  echo "cscope is not present!"
endif


" Shortcuts
set timeout timeoutlen=1000
" omni completion
inoremap <C-n> <C-x><C-o>

" invoke indexer script
nmap <silent> <F2> :!./indexer.sh<CR>:cs reset<CR>:echom 'Index updated'<CR>

" go to next location
map <C-Up>    <C-i>                       

" go to previous location
map <C-Down>  <C-o>                       

" perform build
map <C-b>     :make<CR>:cwindow<CR>       

" perform test
map <C-v>     :make test<CR>              

" search currently selected word
map <C-f> *                               

" toggle project tree
map <C-a> :NERDTreeTabsToggle<CR>         

" focus window left
map <C-Left>  :w<CR><C-W><Left>

" focus window right
map <C-Right> :w<CR><C-W><Right>                  

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
    map <C-Right> :diffget<CR>
endif


" Functions

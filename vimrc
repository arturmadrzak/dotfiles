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
let g:nerdtree_tabs_open_on_console_startup = 0       " don't open NERDTree on startup
autocmd FileType nerdtree noremap <buffer> <C-Left> <Nop>
autocmd FileType nerdtree noremap <buffer> <C-Right> <Nop>

" Indexer
"" vim-easytags
set tags=./tags;                                          " let Vim walk up directory hierarchy looking for tags file
let g:easytags_dynamic_files = 0                          " let vim look for project tags file
let g:easytags_async = 1                                  " let generate tags in background
let g:easytags_events = ['BufWritePost']                  " reindex on buffer write or read
let g:easytags_resolve_links = 2                          " follow symlinks

set completeopt=longest,menuone

if has("cscope")
  set csto=0                              " search cscope before ctags
"    if filereadable('cscope.out')
"    cs add cscope.out                     " if database exists, load it
"  endif
  set cscopeverbose                       " make cscope be verbose
  nmap <C-g> :w<CR>:cs find s <C-R>=expand("<cword>")<CR><CR>   " find symbol references
  nmap <C-e> :w<CR>:cs find g <C-R>=expand("<cword>")<CR><CR>   " find symbol definition

  " TODO: it's possible to define more sophisticated find types... but do i
  " really need it?
else
  echo "cscope is not present!"
endif

" Shortcuts
map <C-Left>  :bp<CR>                     " pervious buffer
map <C-Right> :bn<CR>                     " next buffer
map <C-Up>    <C-i>                       " go to next location
map <C-Down>  <C-o>                       " go to previous location
map <C-b>     :make<CR>:cwindow<CR>       " perform build
map <C-v>     :make test<CR>              " perform test
map <C-f> *                               " search currently selected word
map <C-a> :NERDTreeTabsToggle<CR>         " toggle project tree on Ctrl-M 

" Functions

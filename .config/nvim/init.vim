if has('nvim')
	set runtimepath+=/usr/share/vim/vimfiles
endif

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.config/nvim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" *********************** PLUGINS
Plugin 'VundleVim/Vundle.vim'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'tpope/vim-fugitive'
Plugin 'nathanaelkane/vim-indent-guides'


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" *********************** STYLE
" *** Basics
syntax on
set background=dark
set hlsearch
set number
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
set mouse-=a

" *** Indent Guides
let g:indent_guides_enable_on_vim_startup = 1


" *********************** KEY BINDINGS
" *** Tab Management
nmap <C-T> :tabnew<CR>
nmap <C-\> :tabnext<CR>
nmap <C-S-\> :tabprev<CR>
imap <C-\> <ESC><C-\>
imap <C-S-\> <ESC><C-S-\>

" Map Ctrl-A -> Start of line, Ctrl-E -> End of line
map <C-A> <Home>
map <C-E> <End>


" *********************** CONFIGS
" *** EditorConfig
let g:EditorConfig_exclude_patterns = ['fugitive://.\*', 'scp://.\*']


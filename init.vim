" config by default
set shell=sh
set relativenumber
hi Comment guifg=#ABCDEF 
set smartindent
set expandtab
set shiftwidth=2
set softtabstop=2
set clipboard=unnamedplus

autocmd FileType html setlocal shiftwidth=2 tabstop=2
autocmd FileType python setlocal expandtab shiftwidth=4 softtabstop=4

nnoremap <S-Up> :m-2<CR>
nnoremap <S-Down> :m+<CR>
inoremap <S-Up> <Esc>:m-2<CR>
inoremap <S-Down> <Esc>:m+<CR>

" Specify a directory for plugins For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')
Plug 'valloric/youcompleteme'
" smart ide
Plug 'jiangmiao/auto-pairs'
Plug 'dense-analysis/ale'

" clipBoard
Plug 'roxma/vim-tmux-clipboard'
Plug 'tmux-plugins/vim-tmux-focus-events'

" html
" add this line to your .vimrc file
Plug 'jceb/emmet.snippets'

" indent visuel
Plug 'yggdroot/indentline'
Plug 'lepture/vim-jinja'
Plug "pangloss/vim-javascript"

" javaScrip syntax
Plug 'jelera/vim-javascript-syntax'
Plug 'maxmellon/vim-jsx-pretty'

" go to the file js
Plug 'feix760/vim-javascript-gf'

" javascript autoCompletion
Plug 'posva/vim-vue'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" python color text
Plug 'notpratheek/pychimp-vim' 

" barre bottom
Plug 'vim-airline/vim-airline'
" autocomplet ultisnips

Plug 'roxma/LanguageServer-php-neovim',  {'do': 'composer install && composer run-script parse-stubs'}
Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': 'bash install.sh' }

Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" theme 
Plug 'nanotech/jellybeans.vim'

" search to the files
Plug 'rking/ag.vim'


"NeerTree
Plug 'preservim/nerdtree'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'kien/ctrlp.vim'

" shortcut white tmux for handler of screen
Plug 'christoomey/vim-tmux-navigator'

" Snippets are separated from the engine. Add this if you want them:
Plug 'honza/vim-snippets'

" Track the engine.
Plug 'SirVer/ultisnips'

" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }


 Initialize plugin system
call plug#end()

" snippet
" Or map each action separately
let g:deoplete#enable_at_startup = 1

let g:UltiSnipsExpandTrigger="<bar>"
let g:ycm_key_list_select_completion = ['<TAB>', '<Down>']
let g:UltiSnipsEditSplit="vertical"

" set hidden

let g:LanguageClient_serverCommands = {
    \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
    \ 'javascript': ['/usr/local/bin/javascript-typescript-stdio'],
    \ 'javascript.jsx': ['tcp://127.0.0.1:2089'],
    \ 'python': ['/usr/local/bin/pyls'],
    \ 'ruby': ['~/.rbenv/shims/solargraph', 'stdio'],
    \ 'php': ['intelephense', '--stdio'],
    \ 'vue': ['vls'],
    \ }

let g:LanguageClient_loadSettings=1
let g:LanguageClient_settingsPath='~/vueAutoComplet/settings.json'

nnoremap <F5> :call LanguageClient_contextMenu()<CR>
" Or map each action separately
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>

" fzf mapping
" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

command! -bang -nargs=? -complete=dir Files call fzf#vim#files(<q-args>, <bang>0)

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

" Advanced customization using Vim function
inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'left': '15%'})1

" neertree
map <C-n> :NERDTreeToggle<CR>

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") && v:this_session == "" | NERDTree | endif
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" nerdtree git

let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }

" controle P 
  set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
  set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe  " Windows

  let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
  let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/]\.(git|hg|svn)$',
    \ 'file': '\v\.(exe|so|dll)$',
    \ 'link': 'some_bad_symbolic_links',
    \ }

"theme vim 
" enable the theme
colorscheme jellybeans

" If you configure g:ale_pattern_options outside of vimrc, you need this.
let g:ale_pattern_options_enabled = 1
let g:ale_list_window_size = 5
au BufNewFile,BufRead *.html,*.htm,*.shtml,*.stm,*.twig set ft=jinja

let g:used_javascript_libs = 'vue, react'
autocmd BufReadPre *.js let b:javascript_lib_use_vue = 1
let g:vue_pre_processors = ['scss']


" ////////////// VIM AIR LINE ////////////

let g:airline#extensions#tabline#enabled = 1

let g:airline#extensions#tabline#formatter = 'unique_tail_improved'


" ///////////// Controlp //////////////////

set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe  " Windows

let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

let g:ctrlp_user_command = 'find %s -type f'        " MacOSX/Linux

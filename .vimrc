filetype plugin on

nnoremap <A-Left> :tabprevious<CR>
nnoremap <A-Right> :tabnext<CR>
map <leader>te :tabedit <C-r>=escape(expand("%:p:h"), " ")<cr>/

au BufNewFile,BufRead *.*
    \	set expandtab         |
    \	set autoindent        |
    \	set tabstop=4	      |
    \	set softtabstop=4     |
    \	set shiftwidth=4      |
    \   set number            |
    \   set ruler             |
    \   set termguicolors     |
    \   set wildmenu          |
    \   set cmdheight=1       |
    \   set ignorecase        |
    \   set hlsearch          |
    \   set showmatch         |
    \   set noswapfile        |
    \   set nowb              |
    \   set nobackup          |
    \   syntax enable

set autoread
au FocusGained,BufEnter * checktime

if has('clipboard')
  if has('unnamedplus')
    set clipboard=unnamed,unnamedplus
  else
    set clipboard=unnamed
  endif
endif

if maparg('<C-l>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif

let g:ale_linters = {
    \   'bash': ['shellcheck'],
    \   'python': ['ruff'],
\}

let g:ale_fixers = {
    \   'python': ['black'],
\}

nmap <silent> <A-Up> <Plug>(ale_previous_wrap)
nmap <silent> <A-Down> <Plug>(ale_next_wrap)

let g:ale_python_black_options='--line-length=120 --target-version=py311'
let g:ale_python_ruff_options='--line-length=120'
let g:ale_fix_on_save=1
let g:ale_set_highlights=1
let g:ale_lint_on_text_changed='never'
let g:ale_lint_on_insert_leave=0
let g:ale_lint_on_enter=0
let g:ale_lint_on_save=1

command L ALELint
command F ALEFix

colorscheme gruvbox

set tabstop=2
set shiftwidth=2

set cursorline
set laststatus=2 " enable lightline

"-- Edition ------------
syn on
set hls
set nu
set et

" Cancel last search command
nmap <silent> ,, :nohlsearch<CR>

" Trigger autoformat on ',k'
noremap ,k :Autoformat<CR>

" Lignes autour du curseur
set so=7

set colorcolumn=80

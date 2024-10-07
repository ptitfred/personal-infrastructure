colorscheme gruvbox

let g:airline_powerline_fonts = 1

set tabstop=2
set shiftwidth=2

set cursorline
set laststatus=2 " enable lightline

"-- Telescope ----------
noremap ff :Telescope find_files<CR>
noremap fg :Telescope live_grep<CR>
noremap fb :Telescope buffers<CR>
noremap fh :Telescope help_tags<CR>

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

function! DoPrettyXML()
  " save the filetype so we can restore it later
  let l:origft = &ft
  set ft=
  " delete the xml header if it exists. This will
  " permit us to surround the document with fake tags
  " without creating invalid xml.
  1s/<?xml .*?>//e
  " insert fake tags around the entire document.
  " This will permit us to pretty-format excerpts of
  " XML that may contain multiple top-level elements.
  0put ='<PrettyXML>'
  $put ='</PrettyXML>'
  silent %!xmllint --format -
  " xmllint will insert an <?xml?> header. it's easy enough to delete
  " if you don't want it.
  " delete the fake tags
  2d
  $d
  " restore the 'normal' indentation, which is one extra level
  " too deep due to the extra tags we wrapped around the document.
  silent %<
  " back to home
  1
  " restore the filetype
  exe "set ft=" . l:origft
endfunction
command! Fxml call DoPrettyXML()

function! DoPrettyJSON()
  silent %!jq
endfunction
command! Fjson call DoPrettyJSON()

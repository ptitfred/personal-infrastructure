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

lua << EOF
  require('nvim-autopairs').setup({ map_cr = true })

  local lsp = require('lspconfig')

  local opts = { noremap=true, silent=true }
  vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  vim.api.nvim_set_keymap('n', '[d',       '<cmd>lua vim.diagnostic.goto_prev()<CR>',  opts)
  vim.api.nvim_set_keymap('n', ']d',       '<cmd>lua vim.diagnostic.goto_next()<CR>',  opts)
  vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD',    '<cmd>lua vim.lsp.buf.declaration()<CR>',    opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd',    '<cmd>lua vim.lsp.buf.definition()<CR>',     opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi',    '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr',    '<cmd>lua vim.lsp.buf.references()<CR>',     opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K',     '<cmd>lua vim.lsp.buf.hover()<CR>',          opts)
  end

  lsp.hls.setup {
    settings = {
      haskell = {
        formattingProvider = "stylish-haskell"
      }
    },
    on_attach = on_attach,
    flags = {
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150,
    }
  }
  lsp.rust_analyzer.setup{
    on_attach = on_attach,
    settings = {
      ['rust_analyzer'] = {
        checkOnSave = {
          command = "clippy";
        },
        diagnostics = {
          enable = true;
        }
      }
    }
  }

  local hover = require('hover')
  hover.setup {
      init = function()
          -- Require providers
          require("hover.providers.lsp")
          require('hover.providers.gh')
          -- require('hover.providers.gh_user')
          -- require('hover.providers.jira')
          -- require('hover.providers.man')
          require('hover.providers.dictionary')
      end,
      preview_opts = {
          border = 'single'
      },
      -- Whether the contents of a currently open hover window should be moved
      -- to a :h preview-window when pressing the hover keymap.
      preview_window = false,
      title = true,
      mouse_providers = {
          'LSP'
      },
      mouse_delay = 1000
  }

  -- Setup keymaps
  vim.keymap.set("n", "K",  hover.hover,        {desc = "hover.nvim"}         )
  vim.keymap.set("n", "gK", hover.hover_select, {desc = "hover.nvim (select)"})
  vim.keymap.set("n", "<C-p>", function() hover.hover_switch("previous") end, {desc = "hover.nvim (previous source)"})
  vim.keymap.set("n", "<C-n>", function() hover.hover_switch("next") end, {desc = "hover.nvim (next source)"})

  -- Mouse support
  vim.keymap.set('n', '<MouseMove>', hover.hover_mouse, { desc = "hover.nvim (mouse)" })
  vim.o.mousemoveevent = true
EOF

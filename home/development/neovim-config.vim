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

  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' },     -- For vsnip users.
      -- { name = 'luasnip' },   -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' },    -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  local lsp = require('lspconfig')

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(_, bufnr)
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...)
    end

      -- Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { buffer = bufnr, noremap = true, silent = true }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "ga", vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
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

  -- Set completeopt to have a better completion experience
  -- :help completeopt
  -- menuone: popup even when there's only one match
  -- noinsert: Do not insert text until a selection is made
  -- noselect: Do not auto-select, nvim-cmp plugin will handle this for us.
  vim.o.completeopt = "menuone,noinsert,noselect"

  -- Avoid showing extra messages when using completion
  vim.opt.shortmess = vim.opt.shortmess + "c"
EOF

require('nvim-autopairs').setup({ map_cr = true })

local cmp = require'cmp'
local lspkind = require('lspkind')
cmp.setup {
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
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-b>']     = cmp.mapping.scroll_docs(-4),
    ['<C-f>']     = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>']     = cmp.mapping.abort(),
    -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>']      = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'buffer' },
  },
  formatting = {
    format = lspkind.cmp_format {
      mode = 'text',
      maxwidth = 50,
      ellipsis_char = '…',
      show_labelDetails = true,
      before = function(entry, vim_item)
        return vim_item
      end
    }
  }
}

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
  local list_workspace_folders = function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end
  vim.keymap.set('n', 'gD',        vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd',        vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K',         vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi',        vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "ga",        vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<C-k>',     vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set('n', '<space>wl', list_workspace_folders, opts)
  vim.keymap.set('n', '<space>D',  vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', 'gr',        vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<space>e',  vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '[d',        vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d',        vim.diagnostic.goto_next, opts)
  vim.keymap.set('n', '<space>q',  vim.diagnostic.setloclist, opts)

  vim.lsp.buf.inlay_hint(bufnr, true)
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
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = {
        command = "clippy";
      },
      diagnostics = {
        enable = true;
      },
      editor = {
        formatOnType = true;
      },
      inlayHints = {
        enable = true,
        showParameterNames = true,
        parameterHintsPrefix = "<- ",
        otherHintsPrefix = "=> ",
      },
      completion = {
        snippets = {
          custom = {
            ['thread spawn'] = {
              prefix = { "spawn", "tspawn" },
              body = {
                "thread::spawn(move || {",
                "\t$0",
                "});",
              },
              description = "Insert a thread::spawn call",
              requires = "std::thread",
              scope = "expr",
            }
          }
        }
      }
    }
  }
}
lsp.marksman.setup {
  on_attach = on_attach,
}
lsp.lua_ls.setup {
  on_attach = on_attach,
  settings = {
    Lua = {
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
    },
  },
}

local hover = require('hover')
hover.setup {
    init = function()
        -- Require providers
        require("hover.providers.lsp")
        require('hover.providers.gh')
        require('hover.providers.gh_user')
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
local hover_previous_source = function ()
  hover.hover_switch("previous")
end
local hover_next_source = function ()
  hover.hover_switch("next")
end
vim.keymap.set("n", "K",     hover.hover,           {desc = "hover.nvim"                  })
vim.keymap.set("n", "gK",    hover.hover_select,    {desc = "hover.nvim (select)"         })
vim.keymap.set("n", "<C-p>", hover_previous_source, {desc = "hover.nvim (previous source)"})
vim.keymap.set("n", "<C-n>", hover_next_source,     {desc = "hover.nvim (next source)"    })

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

require('Comment').setup()

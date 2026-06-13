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
  local toggle_inlay_hint = function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
  end
  local hover = function()
    vim.lsp.buf.hover({ border = "rounded", })
  end

  vim.keymap.set('n', 'gD',        vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd',        vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K',         hover, opts)
  vim.keymap.set('n', 'gi',        vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "ga",        vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "gh",        toggle_inlay_hint, opts)
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

  vim.diagnostic.config({ virtual_text = true })

  vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
end

vim.lsp.config('*', {
  on_attach = on_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

local function setup_lsp(name, config)
  vim.lsp.config(name, config or {})
  vim.lsp.enable(name)
end

setup_lsp('hls', {
  filetypes = { 'haskell' },
  settings = {
    haskell = {
      formattingProvider = "stylish-haskell"
    }
  },
})

setup_lsp('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  settings = {
    ['rust-analyzer'] = {
      -- checkOnSave = {
      --   command = "clippy";
      -- },
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
})

setup_lsp('rumdl', {
  cmd = { 'rumdl', 'server' },
  filetypes = { 'markdown' },
  root_markers = { '.git' },
})
setup_lsp('lua_ls', {
  settings = {
    Lua = {
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
    },
  },
})
setup_lsp('nil_ls')
setup_lsp('bashls')
setup_lsp('elixirls', {
  cmd = { "elixir-ls" },
})
setup_lsp('ts_ls')
setup_lsp('eslint')

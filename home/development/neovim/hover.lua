local hover = require('hover')
hover.config({
  providers = {
    {
      module = 'hover.providers.diagnostic',
      priority = 2000,
      name = 'Diags'
    },
    "hover.providers.lsp",
    'hover.providers.gh',
    'hover.providers.gh_user',
    'hover.providers.man',
    'hover.providers.dictionary',
    -- 'hover.providers.jira',
  },
  preview_opts = {
    border = 'single'
  },
  -- Whether the contents of a currently open hover window should be moved
  -- to a :h preview-window when pressing the hover keymap.
  preview_window = false,
  title = true,
  mouse_providers = {
    {
      module = 'hover.providers.diagnostic',
      priority = 2000,
      name = 'Diags'
    },
    'hover.providers.lsp',
    'hover.providers.man',
    'hover.providers.dictionary',
  },
  mouse_delay = 1000
})

-- Setup keymaps
local function hover_previous_source() hover.switch("previous") end
local function hover_next_source()     hover.switch("next")     end

vim.keymap.set("n", "K",     hover.open,            { desc = "hover.nvim (open)"            })
vim.keymap.set("n", "gK",    hover.enter,           { desc = "hover.nvim (select)"          })
vim.keymap.set("n", "<C-p>", hover_previous_source, { desc = "hover.nvim (previous source)" })
vim.keymap.set("n", "<C-n>", hover_next_source,     { desc = "hover.nvim (next source)"     })

-- Mouse support
vim.keymap.set('n', '<MouseMove>', hover.mouse, { desc = "hover.nvim (mouse)" })
vim.o.mousemoveevent = true

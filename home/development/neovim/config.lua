require('nvim-autopairs').setup({ map_cr = true })
require('fidget').setup {}

require('Comment').setup()

require('telescope').setup {
  extensions = {
    lsp_handlers = {
      code_action = {
        telescope = require('telescope.themes').get_dropdown {},
      },
    },
  },
}

require('telescope').load_extension('lsp_handlers')
require('telescope').load_extension('ui-select')

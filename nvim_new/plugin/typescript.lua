vim.pack.add {
  'https://github.com/windwp/nvim-ts-autotag',
  'https://github.com/folke/ts-comments.nvim',
}

require('nvim-ts-autotag').setup()

require('ts-comments').setup()

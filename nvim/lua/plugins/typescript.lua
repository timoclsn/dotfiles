return {
  {
    'windwp/nvim-ts-autotag',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    opts = {},
  },
  {
    'folke/ts-comments.nvim',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'dmmulroy/tsc.nvim',
    event = 'VeryLazy',
    config = function()
      require('tsc').setup()
      vim.keymap.set('n', '<leader>tc', '<cmd>TSC<CR>', { desc = '[t]ype [c]heck' })
    end,
  },
}

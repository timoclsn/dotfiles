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
  {
    'marilari88/twoslash-queries.nvim',
    event = 'VeryLazy',
    opts = {
      is_enabled = false,
      multi_line = true,
      highlight = 'Comment',
    },
    config = function()
      require('twoslash-queries').setup {
        is_enabled = false,
        multi_line = true,
        highlight = 'Comment',
      }
      vim.keymap.set('n', '<leader>ti', function()
        vim.cmd 'TwoslashQueriesInspect'
        vim.cmd 'TwoslashQueriesEnable'
      end, { desc = '[t]ype [i]nspect' })
    end,
  },
}

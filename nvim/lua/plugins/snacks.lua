return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      quickfile = {},
      bigfile = {},
      rename = {},
      words = {},
      notifier = {
        style = 'minimal',
      },
      statuscolumn = {},
      input = {
        win = {
          relative = 'cursor',
          row = -3,
          col = 0,
        },
      },
      indent = {
        animate = {
          enabled = false,
        },
      },
    },
    keys = {
      {
        '<leader>wn',
        function()
          require('snacks').notifier.show_history()
        end,
        desc = '[W]orkspace [N]otifications',
      },
      {
        '<C-n>',
        function()
          require('snacks').words.jump(vim.v.count1)
          vim.cmd 'normal! zz'
        end,
        desc = 'Next Reference',
      },
      {
        '<C-S-n>',
        function()
          require('snacks').words.jump(-vim.v.count1)
          vim.cmd 'normal! zz'
        end,
        desc = 'Previous Reference',
      },
    },
  },
}

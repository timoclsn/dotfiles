return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = {},
      image = {
        doc = {
          enabled = false,
        },
      },
      indent = {
        animate = {
          enabled = false,
        },
      },
      input = {
        win = {
          relative = 'cursor',
          row = -3,
          col = 0,
        },
      },
      notifier = {
        style = 'minimal',
      },
      quickfile = {},
      rename = {},
      statuscolumn = {},
      words = {},
    },
    keys = {
      {
        '<leader>wn',
        function()
          require('snacks').notifier.show_history()
        end,
        desc = '[w]orkspace [n]otifications',
      },
      {
        '<C-n>',
        function()
          require('snacks').words.jump(vim.v.count1, true)
          vim.cmd 'normal! zz'
        end,
        desc = 'Next Reference',
      },
      {
        '<C-S-n>',
        function()
          require('snacks').words.jump(-vim.v.count1, true)
          vim.cmd 'normal! zz'
        end,
        desc = 'Previous Reference',
      },
      {
        '<leader>di',
        function()
          Snacks.image.hover()
        end,
        desc = 'Preview [d]ocument [i]mage under cursor',
      },
    },
  },
}

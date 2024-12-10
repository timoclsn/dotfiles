return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      gitbrowse = {},
      rename = {},
      words = {},
      bigfile = {},
      notifier = {
        style = 'minimal',
      },
      quickfile = {},
      statuscolumn = {},
      scratch = {},
      input = {},
      indent = {
        scope = {
          underline = false,
          animate = {
            enabled = false,
          },
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
        '<leader>go',
        function()
          require('snacks').gitbrowse()
        end,
        desc = '[G]it [O]pen',
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
      {
        '<leader>.',
        function()
          require('snacks').scratch { ft = vim.bo.filetype }
        end,
        desc = 'Toggle Scratch Buffer',
      },
      {
        '<leader>S',
        function()
          require('snacks').scratch.select()
        end,
        desc = 'Select Scratch Buffer',
      },
    },
    config = function(_, opts)
      require('snacks').setup(opts)
    end,
  },
}

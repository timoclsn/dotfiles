return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      -- Enabled
      bufdelete = { enabled = true },
      gitbrowse = { enabled = true },
      rename = { enabled = true },
      words = { enabled = true },
      bigfile = { enabled = true },
      notifier = { enabled = true, style = 'minimal' },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },

      -- Disabled
      git = { enabled = false },
      lazygit = { enabled = false },
      notify = { enabled = false },
      terminal = { enabled = false },
      toggle = { enabled = false },
      win = { enabled = false },
      debug = { enabled = false },
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
        '<leader>dd',
        function()
          require('snacks').bufdelete()
        end,
        desc = '[D]ocument [D]elete buffer',
      },
      {
        '<leader>go',
        function()
          require('snacks').gitbrowse()
        end,
        desc = '[G]it [O]pen',
      },
      {
        'ä',
        function()
          require('snacks').words.jump(vim.v.count1)
        end,
        desc = 'Next Reference',
      },
      {
        'ö',
        function()
          require('snacks').words.jump(-vim.v.count1)
        end,
        desc = 'Previous Reference',
      },
    },
    config = function(_, opts)
      require('snacks').setup(opts)
    end,
  },
}

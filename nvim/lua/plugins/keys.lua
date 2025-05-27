return {
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 400,
      spec = {
        { '<leader>d', group = '[d]ocument' },
        { '<leader>s', group = '[s]earch' },
        { '<leader>w', group = '[w]orkspace' },
        { '<leader>t', group = '[t]ypes' },
        { '<leader>h', group = '[h]arpoon' },
        { '<leader>g', group = '[g]it' },
        { '<leader>a', group = '[a]i' },
        { '<leader>y', group = '[y]ank' },
        { '<leader>p', group = '[p]aste' },
        { '<leader>q', group = '[q]uickfix list' },
        { '<leader>b', group = '[b]uffer' },
        { '<leader>i', group = '[i]mports' },
      },
    },
  },
}

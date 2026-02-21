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
        { '<leader>g', group = '[g]it' },
        { '<leader>y', group = '[y]ank' },
        { '<leader>i', group = '[i]mports' },
      },
    },
  },
}

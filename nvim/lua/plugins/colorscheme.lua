return {
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      require('tokyonight').setup()
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },
}

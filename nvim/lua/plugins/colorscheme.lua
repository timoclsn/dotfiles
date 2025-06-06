return {
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
  },
  {
    'rose-pine/neovim',
    priority = 1000,
  },
  {
    'sainnhe/everforest',
    priority = 1000,
  },
  {
    'zenbones-theme/zenbones.nvim',
    dependencies = 'rktjmp/lush.nvim',
    priority = 1000,
  },
}

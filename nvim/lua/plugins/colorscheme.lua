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
    name = 'rose-pine',
    priority = 1000,
  },
  {
    'sainnhe/everforest',
    priority = 1000,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
  },
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
  },
  {
    'sainnhe/gruvbox-material',
    priority = 1000,
  },
  {
    'vague2k/vague.nvim',
    priority = 1000,
  },
  {
    'zenbones-theme/zenbones.nvim',
    dependencies = 'rktjmp/lush.nvim',
    priority = 1000,
  },
}

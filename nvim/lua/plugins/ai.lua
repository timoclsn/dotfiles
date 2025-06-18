return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      copilot_model = 'gpt-4o-copilot',
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = false,
      },
    },
  },
  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    lazy = false,
    build = 'make',
    dependencies = {
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'zbirenbaum/copilot.lua', -- for providers='copilot'
    },
    opts = {
      provider = 'copilot',
      providers = {
        copilot = {
          model = 'claude-3.5-sonnet',
        },
      },
      hints = {
        enabled = false,
      },
      windows = {
        position = 'left',
      },
    },
  },
}

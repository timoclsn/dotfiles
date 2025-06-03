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
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = '<Tab>',
          accept_line = '<S-Tab>',
          prev = '<C-k>',
          next = '<C-j>',
          dismiss = '<C-c>',
        },
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
      --- The below dependencies are optional,
      'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
      'zbirenbaum/copilot.lua', -- for providers='copilot'
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
    opts = {
      provider = 'copilot',
      providers = {
        copilot = {
          -- model = 'claude-3.5-sonnet',
          -- model = 'claude-3.7-sonnet',
          model = 'claude-3.7-sonnet-thought',
          -- tmperature = 1,
          -- max_tokens = 20000,
        },
      },
      hints = {
        enabled = false,
      },
      behaviour = {
        use_cwd_as_project_root = true,
        auto_apply_diff_after_generation = true,
      },
      windows = {
        position = 'left',
        ask = {
          start_insert = false,
        },
      },
    },
  },
}

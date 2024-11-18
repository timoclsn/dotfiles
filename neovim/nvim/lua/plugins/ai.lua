return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        panel = {
          enabled = false,
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          hide_during_completion = true,
          keymap = {
            accept = '<Tab>',
            next = '<C-n>',
            prev = '<C-p>',
            dismiss = '<C-e>',
          },
        },
      }
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'zbirenbaum/copilot.lua' },
      { 'nvim-lua/plenary.nvim' },
    },
    event = 'VeryLazy',
    opts = {
      model = 'claude-3.5-sonnet',
      window = {
        layout = 'float',
        width = 80,
        height = vim.o.lines - 6,
        row = 1,
        col = vim.o.columns - 84,
      },
    },
    keys = {
      -- Open Copilot Chat
      -- { '<leader>aa', '<cmd>CopilotChatOpen<cr>', mode = 'n', desc = 'CopilotChat - Open Chat' },
      -- {
      --   '<leader>aa',
      --   function()
      --     require('CopilotChat').open {
      --       selection = require('CopilotChat.select').selection,
      --       window = {
      --         title = 'Copilot Chat (Selection)',
      --       },
      --     }
      --   end,
      --   mode = 'x',
      --   desc = 'CopilotChat - Chat with Selection',
      -- },
      -- {
      --   '<leader>ab',
      --   function()
      --     require('CopilotChat').open {
      --       selection = require('CopilotChat.select').buffer,
      --       window = {
      --         title = 'Copilot Chat (Buffer)',
      --       },
      --     }
      --   end,
      --   desc = 'CopilotChat - Chat with Buffer',
      -- },
      -- Code related commands
      -- { '<leader>ae', '<cmd>CopilotChatExplain<cr>', mode = 'x', desc = 'CopilotChat - Explain code' },
      -- { '<leader>at', '<cmd>CopilotChatTests<cr>', mode = 'x', desc = 'CopilotChat - Generate tests' },
      -- { '<leader>ar', '<cmd>CopilotChatReview<cr>', mode = 'x', desc = 'CopilotChat - Review code' },
      -- Generate commit message based on the git diff
      {
        '<leader>am',
        '<cmd>CopilotChatCommit<cr>',
        desc = 'CopilotChat - Generate commit message for all changes',
      },
      {
        '<leader>aM',
        '<cmd>CopilotChatCommitStaged<cr>',
        desc = 'CopilotChat - Generate commit message for staged changes',
      },
      -- Debug
      -- { '<leader>ad', '<cmd>CopilotChatDebugInfo<cr>', desc = 'CopilotChat - Debug Info' },
      -- Fix the issue with diagnostic
      -- { '<leader>af', '<cmd>CopilotChatFixDiagnostic<cr>', desc = 'CopilotChat - Fix Diagnostic' },
      -- Clear buffer and chat history
      -- { '<leader>al', '<cmd>CopilotChatReset<cr>', desc = 'CopilotChat - Clear buffer and chat history' },
    },
  },
  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    build = 'make',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- The below dependencies are optional,
      'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
      'zbirenbaum/copilot.lua', -- for providers='copilot'
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
    config = function()
      require('avante_lib').load()
      require('avante').setup {
        provider = 'copilot',
        copilot = {
          model = 'claude-3.5-sonnet',
        },
        hints = { enabled = false },
        windows = {
          ask = {
            start_insert = false,
          },
        },
      }
    end,
  },
  -- {
  --   'olimorris/codecompanion.nvim',
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     'nvim-treesitter/nvim-treesitter',
  --     'hrsh7th/nvim-cmp', -- Optional: For using slash commands and variables in the chat buffer
  --     'nvim-telescope/telescope.nvim', -- Optional: For using slash commands
  --     { 'stevearc/dressing.nvim', opts = {} }, -- Optional: Improves `vim.ui.select`
  --   },
  --   config = function()
  --     require('codecompanion').setup {
  --       strategies = {
  --         chat = {
  --           adapter = 'copilot',
  --         },
  --         inline = {
  --           adapter = 'copilot',
  --         },
  --         agent = {
  --           adapter = 'copilot',
  --         },
  --       },
  --     }
  --   end,
  -- },
}

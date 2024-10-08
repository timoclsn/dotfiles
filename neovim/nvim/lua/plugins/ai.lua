return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = '<Tab>',
            next = '<C-n>',
            prev = '<C-p>',
            dismiss = '<Esc>',
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
      window = {
        layout = 'float',
        width = 100,
        height = vim.o.lines - 6,
        row = 1,
        col = vim.o.columns - 124,
      },
    },
    keys = {
      -- Open Copilot Chat
      { '<leader>aa', '<cmd>CopilotChatOpen<cr>', mode = 'n', desc = 'CopilotChat - Open Chat' },
      {
        '<leader>aa',
        function()
          require('CopilotChat').open {
            selection = require('CopilotChat.select').selection,
            window = {
              title = 'Copilot Chat (Selection)',
            },
          }
        end,
        mode = 'x',
        desc = 'CopilotChat - Chat with Selection',
      },
      {
        '<leader>ab',
        function()
          require('CopilotChat').open {
            selection = require('CopilotChat.select').buffer,
            window = {
              title = 'Copilot Chat (Buffer)',
            },
          }
        end,
        desc = 'CopilotChat - Chat with Buffer',
      },
      -- Code related commands
      { '<leader>ae', '<cmd>CopilotChatExplain<cr>', mode = 'x', desc = 'CopilotChat - Explain code' },
      { '<leader>at', '<cmd>CopilotChatTests<cr>', mode = 'x', desc = 'CopilotChat - Generate tests' },
      { '<leader>ar', '<cmd>CopilotChatReview<cr>', mode = 'x', desc = 'CopilotChat - Review code' },
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
      { '<leader>ad', '<cmd>CopilotChatDebugInfo<cr>', desc = 'CopilotChat - Debug Info' },
      -- Fix the issue with diagnostic
      { '<leader>af', '<cmd>CopilotChatFixDiagnostic<cr>', desc = 'CopilotChat - Fix Diagnostic' },
      -- Clear buffer and chat history
      { '<leader>al', '<cmd>CopilotChatReset<cr>', desc = 'CopilotChat - Clear buffer and chat history' },
    },
  },
}

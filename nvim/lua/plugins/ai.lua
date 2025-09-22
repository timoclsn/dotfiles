return {
  {
    'zbirenbaum/copilot.lua',
    dependencies = {
      'copilotlsp-nvim/copilot-lsp',
    },
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = '<Tab>',
          accept_line = '<S-Tab>',
          dismiss = '<C-e>',
        },
      },
      nes = {
        enabled = true,
        keymap = {
          accept_and_goto = '<leader>a',
          dismiss = '<Esc>',
        },
      },
    },
  },
}

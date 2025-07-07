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
}

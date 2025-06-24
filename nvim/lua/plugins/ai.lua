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
}

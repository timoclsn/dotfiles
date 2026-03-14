vim.pack.add {
  'https://github.com/zbirenbaum/copilot.lua',
}

require('copilot').setup {
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
}

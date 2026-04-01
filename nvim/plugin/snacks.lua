vim.pack.add {
  'https://github.com/folke/snacks.nvim',
}

require('snacks').setup {
  bigfile = {},
  image = {
    doc = {
      enabled = false,
    },
  },
  indent = {
    animate = {
      enabled = false,
    },
  },
  input = {
    win = {
      relative = 'cursor',
      row = -3,
      col = 0,
    },
  },
  notifier = {
    style = 'minimal',
  },
  quickfile = {},
  rename = {},
  statuscolumn = {},
  words = {},
}

vim.keymap.set('n', '<leader>wn', function()
  require('snacks').notifier.show_history()
end, { desc = '[w]orkspace [n]otifications' })

vim.keymap.set('n', '<C-n>', function()
  require('snacks').words.jump(vim.v.count1, true)
  vim.cmd 'normal! zz'
end, { desc = 'Next Reference' })

vim.keymap.set('n', '<C-S-n>', function()
  require('snacks').words.jump(-vim.v.count1, true)
  vim.cmd 'normal! zz'
end, { desc = 'Previous Reference' })

vim.keymap.set('n', '<leader>di', function()
  Snacks.image.hover()
end, { desc = 'Preview [d]ocument [i]mage under cursor' })

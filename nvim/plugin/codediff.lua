-- codediff's own plugin file registers :CodeDiff, highlights and the virtual
-- file scheme lazily, so only the config is applied here. Going through
-- codediff.setup would pull in the whole diff UI at startup.
require('codediff.config').setup {
  diff = {
    layout = 'inline',
  },
  keymaps = {
    view = {
      quit = 'q',
      toggle_explorer = '<C-e>',
      toggle_layout = 'leader<t>',
    },
    explorer = {
      select = 'l',
    },
  },
}

vim.keymap.set('n', '<leader>gd', function()
  vim.cmd 'CodeDiff'
end, { desc = '[g]it [d]iff against index' })

vim.keymap.set('n', '<leader>gD', function()
  vim.cmd 'CodeDiff develop..HEAD'
end, { desc = '[g]it diff against [D]evelop' })

vim.keymap.set('n', '<leader>gM', function()
  vim.cmd 'CodeDiff main..HEAD'
end, { desc = '[g]it diff against [M]ain' })

vim.keymap.set('n', '<leader>gf', function()
  vim.cmd ':CodeDiff history %'
end, { desc = '[g]it [f]ile history' })

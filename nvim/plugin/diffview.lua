require('diffview').setup {
  file_panel = {
    win_config = {
      width = 60,
    },
  },
}

vim.keymap.set('n', '<leader>gd', function()
  if next(require('diffview.lib').views) == nil then
    vim.cmd 'DiffviewOpen'
  else
    vim.cmd 'DiffviewClose'
  end
end, { desc = '[g]it [d]iff against index' })

vim.keymap.set('n', '<leader>gD', function()
  if next(require('diffview.lib').views) == nil then
    vim.cmd 'DiffviewOpen develop'
  else
    vim.cmd 'DiffviewClose'
  end
end, { desc = '[g]it diff against [D]evelop' })

vim.keymap.set('n', '<leader>gM', function()
  if next(require('diffview.lib').views) == nil then
    vim.cmd 'DiffviewOpen main'
  else
    vim.cmd 'DiffviewClose'
  end
end, { desc = '[g]it diff against [M]ain' })

vim.keymap.set('n', '<leader>gh', function()
  if next(require('diffview.lib').views) == nil then
    vim.cmd 'DiffviewOpen HEAD~1'
  else
    vim.cmd 'DiffviewClose'
  end
end, { desc = '[g]it diff against [h]ead - 1 (last two commits)' })

vim.keymap.set('n', '<leader>gf', function()
  if next(require('diffview.lib').views) == nil then
    vim.cmd 'DiffviewFileHistory %'
  else
    vim.cmd 'DiffviewClose'
  end
end, { desc = '[g]it [f]ile history' })

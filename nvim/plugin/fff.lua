require('fff').setup {
  lazy_sync = true,
  prompt = '> ',
  title = 'Search Files',
  prompt_vim_mode = true,
}

vim.keymap.set('n', '<leader>sf', function()
  require('fff').find_files()
end, { desc = '[s]earch [f]iles' })

vim.keymap.set('n', '<leader>sg', function()
  require('fff').live_grep { grep = { modes = { 'fuzzy', 'plain', 'regex', 'definition_only' } } }
end, { desc = '[s]earch by [g]rep' })

vim.keymap.set({ 'n', 'x' }, '<leader>sw', function()
  require('fff').live_grep_under_cursor()
end, { desc = '[s]earch current [w]ord / selection' })

vim.keymap.set('x', '<leader>sg', function()
  require('fff').live_grep_under_cursor()
end, { desc = '[s]earch selection by [g]rep' })

vim.keymap.set('n', '<leader>s.', '<cmd>FFFResume<CR>', { desc = '[s]earch resume ("." for repeat)' })

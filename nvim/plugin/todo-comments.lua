require('todo-comments').setup()
vim.keymap.set('n', '<leader>sy', '<cmd>:TodoTelescope<CR>', { desc = '[s]earch [y] todo comments' })

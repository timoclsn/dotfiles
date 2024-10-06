-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Jump half page down and center cursor' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Jump half page up and center cursor' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next Search Result Centered' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous Search Result Centered' })
vim.keymap.set('v', '<leader>p', [["_dP]], { desc = 'Paste without copying' })
vim.keymap.set({ 'n', 'v' }, '<leader>d', [["_d]], { desc = 'Delete without copying' })
vim.keymap.set('n', '<C-p>', '<C-i>', { desc = 'Go forward in jumplist' }) -- Use C-p in tmux nvim because broken C-i mapping
vim.keymap.set('n', '<C-i>', '<C-i>', { desc = 'Go forward in jumplist' }) -- Fix C-i in non tmux nvim
vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Exit Insert Mode' })
vim.keymap.set('n', '<C-s>', ':w<CR>', { desc = 'Write File' })
vim.keymap.set('n', '<C-S-s>', ':wa<CR>', { desc = 'Write All Files' })
vim.keymap.set('n', 'H', '^', { desc = 'Goto first character of line' })
vim.keymap.set('n', 'L', '$', { desc = 'Goto last character of line' })

vim.keymap.set('n', '<leader>o', function()
  vim.lsp.buf.execute_command {
    command = '_typescript.organizeImports',
    arguments = { vim.api.nvim_buf_get_name(0) },
    title = '',
  }
end, { desc = '[O]rganize Imports' })

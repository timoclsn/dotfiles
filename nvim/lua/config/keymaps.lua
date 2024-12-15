-- Disable arrow keys
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')
vim.keymap.set('i', '<left>', '<cmd>echo "Move in normal mode!!"<CR>')
vim.keymap.set('i', '<right>', '<cmd>echo "Move in normal mode!!"<CR>')
vim.keymap.set('i', '<up>', '<cmd>echo "Move in normal mode!!"<CR>')
vim.keymap.set('i', '<down>', '<cmd>echo "Move in normal mode!!"<CR>')

-- General
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Jump half page down and center cursor' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Jump half page up and center cursor' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next Search Result Centered' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous Search Result Centered' })
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"0p', { desc = 'Paste last yanked' })
vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d', { desc = 'Delete without copying' })
vim.keymap.set('n', '<C-i>', '<C-i>', { desc = 'Go forward in jumplist' })
vim.keymap.set('n', '<C-s>', ':w<CR>', { desc = 'Write File' })
vim.keymap.set('n', '<C-S-s>', ':wa<CR>', { desc = 'Write All Files' })
vim.keymap.set('n', 'H', '^', { desc = 'Goto first character of line' })
vim.keymap.set('n', 'L', '$', { desc = 'Goto last character of line' })
vim.keymap.set('n', '<C-f>', '<cmd>silent !tmux neww tmux-sessionizer<CR>')
vim.keymap.set('n', '<leader>o', 'o<ESC>k', { desc = 'Insert line above' })
vim.keymap.set('n', '<leader>O', 'O<ESC>j', { desc = 'Insert line below' })
vim.keymap.set('n', '<leader>k', vim.diagnostic.open_float, { desc = 'Show diagnostic under cursor' })

-- Quickfix list
vim.keymap.set('n', '<leader>qn', '<cmd>cnext<CR>', { desc = '[Q]uickfix list [N]ext item' })
vim.keymap.set('n', '<leader>qp', '<cmd>cprev<CR>', { desc = '[Q]uickfix list [P]revious item' })
vim.keymap.set('n', '<leader>qq', '<cmd>copen<CR>', { desc = '[Q]uickfix list [O]pen' })
vim.keymap.set('n', '<leader>qc', '<cmd>cclose<CR>', { desc = '[Q]uickfix list [C]lose' })
vim.keymap.set('n', '<leader>qo', '<cmd>colder<CR>', { desc = '[Q]uickfix list [O]lder list' })
vim.keymap.set('n', '<leader>qe', '<cmd>cnewer<CR>', { desc = '[Q]uickfix list n[E]wer list' })
vim.keymap.set('n', '<leader>qd', vim.diagnostic.setloclist, { desc = '[Q]uickfix list [D]iagnostics' })

-- Yank
vim.keymap.set('n', '<leader>yb', 'ggVGy', { desc = '[Y]ank [B]uffer content' })

-- This keymap is useful for testing and debugging condiions
vim.keymap.set('n', '<leader>yx', function()
  local line = vim.api.nvim_get_current_line()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local todo = 'TODO: Delete this line and uncomment the one above'
  local cms = vim.bo.commentstring
  local comment_start = cms:match '^(.*)%%s' or '//'
  local comment_end = cms:match '%%s(.*)$' or ''

  -- Insert the uncommented copy first
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, {
    line,
    line .. ' ' .. comment_start .. todo .. comment_end,
  })

  -- Move cursor to first line and comment it with gcc
  vim.api.nvim_win_set_cursor(0, { row, 0 })
  vim.cmd 'normal gcc'

  -- Move cursor to first non-empty character of the second line
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
  vim.cmd 'normal! ^'
end, { desc = '[Y]ank [X] - duplicate and comment line' })

-- Keymap to revert the above keymap
vim.keymap.set('n', '<leader>yc', function()
  vim.cmd 'normal! dd'
  vim.cmd 'normal! k'
  vim.cmd 'normal gcc'
  vim.cmd 'normal! ^'
end, { desc = '[Y]ank [C] - revert duplicate and comment line' })

vim.keymap.set('n', '<leader>yp', function()
  -- Get the current buffer's full path
  local full_path = vim.fn.expand '%:p'

  -- Get the project root directory
  local root_dir = vim.fn.systemlist('git rev-parse --show-toplevel')[1]

  -- If not in a git repo, try to use the current working directory
  if vim.v.shell_error ~= 0 then
    root_dir = vim.fn.getcwd()
  end

  -- Ensure root_dir ends with a separator
  if root_dir:sub(-1) ~= '/' then
    root_dir = root_dir .. '/'
  end

  -- Remove the root directory from the full path to get the relative path
  local relative_path = full_path:sub(#root_dir + 1)

  -- Copy to clipboard
  vim.fn.setreg('+', relative_path)
  print('Copied path to clipboard: ' .. relative_path)
end, { noremap = true, silent = true, desc = '[Y]ank full file [P]ath' })

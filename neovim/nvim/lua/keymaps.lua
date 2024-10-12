-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

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
vim.keymap.set('n', '<leader>qn', '<cmd>cnext<CR>', { desc = '[Q]uickfix list [N]ext item' })
vim.keymap.set('n', '<leader>qp', '<cmd>cprev<CR>', { desc = '[Q]uickfix list [P]revious item' })
vim.keymap.set('n', '<leader>qq', '<cmd>copen<CR>', { desc = '[Q]uickfix list [O]pen' })
vim.keymap.set('n', '<leader>qc', '<cmd>cclose<CR>', { desc = '[Q]uickfix list [C]lose' })
vim.keymap.set('n', '<leader>qo', '<cmd>colder<CR>', { desc = '[Q]uickfix list [O]lder list' })
vim.keymap.set('n', '<leader>qe', '<cmd>cnewer<CR>', { desc = '[Q]uickfix list n[E]wer list' })
vim.keymap.set('n', '<leader>qd', vim.diagnostic.setloclist, { desc = '[Q]uickfix list [D]iagnostics' })

vim.keymap.set('n', '<leader>o', function()
  vim.lsp.buf.execute_command {
    command = '_typescript.organizeImports',
    arguments = { vim.api.nvim_buf_get_name(0) },
    title = '',
  }
end, { desc = '[O]rganize Imports' })

vim.keymap.set('n', '<leader>dc', function()
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
end, { noremap = true, silent = true, desc = '[D]ocument [C]opy full path' })

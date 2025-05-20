-- Disable arrow keys
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')
-- vim.keymap.set('i', '<left>', '<cmd>echo "Move in normal mode!!"<CR>')
-- vim.keymap.set('i', '<right>', '<cmd>echo "Move in normal mode!!"<CR>')
-- vim.keymap.set('i', '<up>', '<cmd>echo "Move in normal mode!!"<CR>')
-- vim.keymap.set('i', '<down>', '<cmd>echo "Move in normal mode!!"<CR>')

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
vim.keymap.set('n', '<leader>k', vim.diagnostic.open_float, { desc = 'Show diagnostic under cursor' })
vim.keymap.set('n', '<leader>K', function()
  vim.diagnostic.config {
    virtual_lines = {
      current_line = true,
    },
    virtual_text = false,
  }
  vim.api.nvim_create_autocmd('CursorMoved', {
    group = vim.api.nvim_create_augroup('line-diagnostics', { clear = true }),
    callback = function()
      vim.diagnostic.config {
        virtual_lines = false,
        virtual_text = true,
      }
      return true
    end,
  })
end, { desc = '[K] show virtual line diagnostics under the cursor' })
vim.keymap.set('n', '<leader>td', function()
  vim.diagnostic.config {
    virtual_lines = not vim.diagnostic.config().virtual_lines,
    virtual_text = not vim.diagnostic.config().virtual_text,
  }
end, { desc = '[t]oggle [d]iagnostic style' })

vim.keymap.set('n', 'gX', function()
  vim.ui.open(vim.fn.expand '<cfile>')
end, { desc = 'Open file/url under cursor' })
vim.keymap.set('n', 'X', '$x', { desc = 'Delete last character in line' })

-- Remap brackets for easier access to brakets keymaps
vim.keymap.set('n', 'ö', '[', { remap = true })
vim.keymap.set('n', 'ä', ']', { remap = true })
vim.keymap.set('n', 'Ö', '{', { remap = true })
vim.keymap.set('n', 'Ä', '}', { remap = true })

-- Quickfix list
vim.keymap.set('n', '<leader>qq', '<cmd>copen<CR>', { desc = '[q]uickfix list [o]pen' })
vim.keymap.set('n', '<leader>qc', '<cmd>cclose<CR>', { desc = '[q]uickfix list [c]lose' })
vim.keymap.set('n', '<leader>qo', '<cmd>colder<CR>', { desc = '[q]uickfix list [o]lder list' })
vim.keymap.set('n', '<leader>qn', '<cmd>cnewer<CR>', { desc = '[q]uickfix list [n]ewer list' })
vim.keymap.set('n', '<leader>qd', vim.diagnostic.setloclist, { desc = '[q]uickfix list [d]iagnostics' })

-- Yank
vim.keymap.set('n', '<leader>yb', 'ggVGy', { desc = '[y]ank [b]uffer content' })
vim.keymap.set('n', '<leader>pb', 'ggVG"+p', { desc = '[p]aste clipboard content and replace [b]uffer content' })
vim.keymap.set('n', '<leader>yd', function()
  local diagnostics = vim.diagnostic.get(0, { line = vim.api.nvim_win_get_cursor(0)[1] - 1 })
  if #diagnostics == 0 then
    vim.notify('No diagnostics found at cursor position', vim.log.levels.INFO)
    return
  end
  local messages = vim.tbl_map(function(d)
    return string.format('[%s] %s', d.source or 'unknown', d.message)
  end, diagnostics)
  vim.fn.setreg('+', table.concat(messages, '\n'))
  vim.notify('Yanked ' .. #diagnostics .. ' diagnostic messages', vim.log.levels.INFO)
end, { desc = '[y]ank [d]iagnostics messages under cursor' })

-- This keymap is useful for testing and debugging conditions
vim.keymap.set('n', '<leader>yx', function()
  local line = vim.api.nvim_get_current_line()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local warn = 'WARN: Delete this line and uncomment the one above'
  local cms = vim.bo.commentstring
  local comment_start = cms:match '^(.*)%%s' or '//'
  local comment_end = cms:match '%%s(.*)$' or ''

  -- Insert the uncommented copy first
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, {
    line,
    line .. ' ' .. comment_start .. warn .. comment_end,
  })

  -- Move cursor to first line and comment it with gcc
  vim.api.nvim_win_set_cursor(0, { row, 0 })
  vim.cmd 'normal gcc'

  -- Move cursor to first non-empty character of the second line
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
  vim.cmd 'normal! ^'
end, { desc = '[y]ank [x] - duplicate and comment line' })

-- Keymap to revert the above keymap
vim.keymap.set('n', '<leader>yc', function()
  vim.cmd 'normal! dd'
  vim.cmd 'normal! k'
  vim.cmd 'normal gcc'
  vim.cmd 'normal! ^'
end, { desc = '[y]ank [c] - revert duplicate and comment line' })

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
end, { noremap = true, silent = true, desc = '[y]ank full file [p]ath' })

vim.keymap.set('n', '<leader>yf', function()
  local full_path = vim.fn.expand '%:p'
  -- Copy the actual file to clipboard using osascript
  local cmd = string.format([[osascript -e 'set the clipboard to (POSIX file "%s")']], full_path)
  vim.fn.system(cmd)
  print('Copied file to clipboard: ' .. full_path)
end, { noremap = true, silent = true, desc = '[y]ank [f]ile to clipboard' })

-- Switch between React component and its style file
vim.keymap.set('n', '<leader>ss', function()
  local current_file = vim.fn.expand '%:p'

  local style_extensions = {
    '.style.ts',
    '.css.ts',
    '.module.css',
    '.module.sass',
  }

  -- Check if current file is a style file
  local is_style_file = false
  local matched_extension = nil
  for _, ext in ipairs(style_extensions) do
    if current_file:match('%' .. ext .. '$') then
      is_style_file = true
      matched_extension = ext
      break
    end
  end

  local is_component_file = current_file:match '%.tsx$'

  if is_style_file then
    -- If we're in a style file, switch to the component
    local component_file = current_file:gsub('%' .. matched_extension .. '$', '.tsx')
    if vim.fn.filereadable(component_file) == 1 then
      vim.cmd('edit ' .. component_file)
    else
      vim.notify('No corresponding component file found', vim.log.levels.WARN)
    end
  elseif is_component_file then
    -- If we're in a component file, try each style file in order
    local found = false
    for _, ext in ipairs(style_extensions) do
      local style_file = current_file:gsub('%.tsx$', ext)
      if vim.fn.filereadable(style_file) == 1 then
        vim.cmd('edit ' .. style_file)
        found = true
        break
      end
    end

    if not found then
      vim.notify('No corresponding style file found', vim.log.levels.WARN)
    end
  else
    vim.notify('Not a React component or style file', vim.log.levels.WARN)
  end
end, { noremap = true, silent = true, desc = '[s]earch [s]tyles' })

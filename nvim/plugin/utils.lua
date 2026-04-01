vim.pack.add {
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/folke/todo-comments.nvim',
  'https://github.com/christoomey/vim-tmux-navigator',
  'https://github.com/axelvc/template-string.nvim',
  'https://github.com/nat-418/boole.nvim',
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  'https://github.com/jinh0/eyeliner.nvim',
}

-- Guess indent
require('guess-indent').setup()

-- Todo comments
require('todo-comments').setup()
vim.keymap.set('n', '<leader>sy', '<cmd>:TodoTelescope<CR>', { desc = '[s]earch [y] todo comments' })

-- Vim-tmux-navigator keymaps
vim.keymap.set('n', '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>')
vim.keymap.set('n', '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>')
vim.keymap.set('n', '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>')
vim.keymap.set('n', '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>')
vim.keymap.set('n', '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>')

-- Template string
require('template-string').setup {
  remove_template_string = true,
}

-- Boole
require('boole').setup {
  mappings = {
    increment = '<C-a>',
    decrement = '<C-x>',
  },
  additions = {
    { 'production', 'development', 'test' },
    { 'prod', 'staging', 'develop', 'test', 'test2', 'test3', 'test4' },
    { 'let', 'const' },
    { 'start', 'end' },
    { 'import', 'export' },
    { 'before', 'after' },
    { 'plus', 'minus' },
    { 'left', 'right' },
    { 'FIX', 'TODO', 'HACK', 'WARN', 'PERF', 'NOTE', 'TEST' },
  },
}

-- Render markdown
require('render-markdown').setup()

-- Eyeliner
require('eyeliner').setup {
  highlight_on_key = true,
}

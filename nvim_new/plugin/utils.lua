vim.pack.add {
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/folke/todo-comments.nvim',
  'https://github.com/christoomey/vim-tmux-navigator',
  'https://github.com/brenoprata10/nvim-highlight-colors',
  'https://github.com/axelvc/template-string.nvim',
  'https://github.com/nat-418/boole.nvim',
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  'https://github.com/jinh0/eyeliner.nvim',
}

-- Ghostty syntax highlighting (local plugin, loaded manually)
local ghostty_path = '/Applications/Ghostty.app/Contents/Resources/vim/vimfiles/'
if vim.fn.isdirectory(ghostty_path) == 1 then
  vim.opt.rtp:prepend(ghostty_path)
end

require('guess-indent').setup()

require('todo-comments').setup()
vim.keymap.set('n', '<leader>sy', '<cmd>:TodoTelescope<CR>', { desc = '[s]earch [y] todo comments' })

require('nvim-highlight-colors').setup {
  render = 'virtual',
  enable_tailwind = true,
}

require('template-string').setup {
  remove_template_string = true,
}

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

require('render-markdown').setup()

require('eyeliner').setup {
  highlight_on_key = true,
}

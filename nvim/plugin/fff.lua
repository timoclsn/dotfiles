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
  require('fff').live_grep {
    grep = {
      modes = { 'fuzzy', 'plain', 'regex' },
    },
  }
end, { desc = '[s]earch by [g]rep' })

vim.keymap.set('n', '<leader>sw', function()
  local word = vim.fn.expand '<cword>'
  require('fff').live_grep {
    query = word,
    grep = {
      modes = { 'plain', 'regex', 'fuzzy' },
    },
  }
end, { desc = '[s]earch current [w]ord' })

vim.keymap.set('x', '<leader>sg', function()
  local visual_selection = function()
    local save_previous = vim.fn.getreg 'a'
    vim.cmd 'noau normal! "ay'
    local selection = vim.fn.getreg 'a'
    vim.fn.setreg('a', save_previous)
    return selection:gsub('\n', ' '):gsub('^%s*(.-)%s*$', '%1')
  end

  local selected_text = visual_selection()

  require('fff').live_grep {
    query = selected_text,
    grep = {
      modes = { 'plain', 'regex', 'fuzzy' },
    },
  }
end, { desc = '[s]earch by [g]rep' })

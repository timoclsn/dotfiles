return {
  {
    'ibhagwan/fzf-lua',
    event = 'VimEnter',
    config = function()
      local fzf = require 'fzf-lua'
      local smart_opener = require 'fzflua.smart_opener'
      local copy_path = require 'fzflua.copy_path'

      fzf.setup {
        actions = {
          files = {
            ['default'] = smart_opener.smart_open,
            ['ctrl-v'] = smart_opener.smart_open_split,
            ['ctrl-y'] = copy_path.copy_path,
          },
        },
      }

      vim.keymap.set('n', '<leader>sf', fzf.files, { desc = '[s]earch [f]iles' })
      vim.keymap.set('n', '<leader>sg', require('fzflua.live_grep'), { desc = '[s]earch by [g]rep' })
      vim.keymap.set('n', '<leader>sh', fzf.help_tags, { desc = '[s]earch [h]elp' })
      vim.keymap.set('n', '<leader>sk', fzf.keymaps, { desc = '[s]earch [k]eymaps' })
      vim.keymap.set('n', '<leader>sr', fzf.registers, { desc = '[s]earch [r]egisters' })
      vim.keymap.set('n', '<leader>sm', fzf.marks, { desc = '[s]earch [m]arks' })
      vim.keymap.set('n', '<leader>st', fzf.builtin, { desc = '[s]earch [t]pickers' })
      vim.keymap.set('n', '<leader>sc', fzf.colorschemes, { desc = '[s]earch [c]olorschemes' })
      vim.keymap.set('n', '<leader>sw', function()
        local word = vim.fn.expand '<cword>'
        require('fzflua.live_grep') { default_text = word }
      end, { desc = '[s]earch current [w]ord' })
      vim.keymap.set('x', '<leader>sg', function()
        local save_previous = vim.fn.getreg 'a'
        vim.cmd 'noau normal! "ay'
        local selection = vim.fn.getreg 'a'
        vim.fn.setreg('a', save_previous)
        require('fzflua.live_grep') { default_text = selection }
      end, { desc = '[s]earch by [g]rep' })
      vim.keymap.set('n', '<leader>wd', fzf.diagnostics_workspace, { desc = '[w]orkspace [d]iagnostics' })
      vim.keymap.set('n', '<leader>dd', fzf.diagnostics_document, { desc = 'Show [d]ocument [d]iagnostics' })
      vim.keymap.set('n', '<leader>s.', fzf.resume, { desc = '[s]earch resume' })
      vim.keymap.set('n', '<leader>so', fzf.oldfiles, { desc = '[s]earch [o]ld files' })
      vim.keymap.set('n', '<leader>sq', fzf.quickfix, { desc = '[s]earch [q]uickfix history' })
      vim.keymap.set('n', '<leader>sp', require('fzflua.packages'), { desc = '[s]earch node [p]ackages' })
      vim.keymap.set('n', '<leader>sl', fzf.luasnip, { desc = '[s]earch [l]uasnip' })
      vim.keymap.set('n', '<leader>/', function()
        fzf.blines { prompt = '/' }
      end, { desc = '[/] Fuzzily search in current buffer' })
      vim.keymap.set('n', '<Tab>', function()
        fzf.buffers { sort_mru = true, ignore_current_buffer = true }
      end, { desc = 'Open Buffers' })
    end,
  },
}

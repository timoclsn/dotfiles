return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'natecraddock/telescope-zf-native.nvim' },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'benfowler/telescope-luasnip.nvim' },
    },
    config = function()
      local actions = require 'telescope.actions'
      local layout_actions = require 'telescope.actions.layout'
      local path_display = require 'telescope.path_display'
      local copy_path = require 'telescope.copy_path'

      require('telescope').setup {
        defaults = {
          scroll_strategy = 'limit',
          mappings = {
            n = {
              ['<Tab>'] = actions.move_selection_next,
              ['<S-Tab>'] = actions.move_selection_previous,
              ['<C-s>'] = actions.toggle_selection,
              ['<C-space>'] = actions.to_fuzzy_refine,
              ['<space>'] = layout_actions.toggle_preview,
              ['<C-y>'] = copy_path.copy_path,
              ['<C-b>'] = actions.results_scrolling_up,
              ['<C-f>'] = actions.results_scrolling_down,
              ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
            },
            i = {
              ['<C-s>'] = actions.toggle_selection,
              ['<C-space>'] = actions.to_fuzzy_refine,
              ['<C-l>'] = layout_actions.cycle_layout_next,
              ['<C-y>'] = copy_path.copy_path,
              ['<C-b>'] = actions.results_scrolling_up,
              ['<C-f>'] = actions.results_scrolling_down,
              ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
            },
          },
          path_display = path_display,
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = { 'rg', '--files', '--color', 'never', '--sortr', 'modified' },
          },
          oldfiles = {
            cwd_only = true,
          },
          buffers = {
            mappings = {
              n = {
                ['d'] = actions.delete_buffer,
              },
            },
          },
        },
        extensions = {
          ['zf-native'] = {},
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
          ['luasnip'] = {},
        },
      }

      pcall(require('telescope').load_extension 'zf-native')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension 'luasnip')

      local builtin = require 'telescope.builtin'

      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[s]earch [f]iles' })
      vim.keymap.set('n', '<leader>sg', require 'telescope.live_grep', { desc = '[s]earch by [g]rep' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[s]earch [h]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[s]earch [k]eymaps' })
      vim.keymap.set('n', '<leader>sr', builtin.registers, { desc = '[s]earch [r]egisters' })
      vim.keymap.set('n', '<leader>sm', builtin.marks, { desc = '[s]earch [m]arks' })
      vim.keymap.set('n', '<leader>st', builtin.builtin, { desc = '[s]earch [t]elescope pickers' })
      vim.keymap.set('n', '<leader>sc', builtin.colorscheme, { desc = '[s]earch [c]olorschemes' })

      vim.keymap.set('n', '<leader>sw', function()
        local word = vim.fn.expand '<cword>'
        require 'telescope.live_grep' { default_text = word }
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
        require 'telescope.live_grep' { default_text = selected_text }
      end, { desc = '[s]earch by [g]rep' })

      vim.keymap.set('n', '<leader>wd', builtin.diagnostics, { desc = '[w]orkspace [d]iagnostics' })
      vim.keymap.set('n', '<leader>dd', function()
        builtin.diagnostics { bufnr = 0 }
      end, { desc = 'Show [d]ocument [d]iagnostics' })
      vim.keymap.set('n', '<leader>s.', builtin.resume, { desc = '[s]earch resume ("." for repeat)' })
      vim.keymap.set('n', '<leader>so', builtin.oldfiles, { desc = '[s]earch [o]ld files' })
      vim.keymap.set('n', '<leader>sq', builtin.quickfixhistory, { desc = '[s]earch [q]uickfix history' })
      vim.keymap.set('n', '<leader>sp', require 'telescope.packages', { desc = '[s]earch node [p]ackages' })
      vim.keymap.set('n', '<leader>sl', '<cmd>:Telescope luasnip<CR>', { desc = '[s]earch [l]uasnip' })

      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<Tab>', function()
        builtin.buffers(require('telescope.themes').get_dropdown {
          scroll_strategy = 'cycle',
          sort_mru = true,
          ignore_current_buffer = true,
          previewer = false,
          winblend = 10,
          initial_mode = 'normal',
          layout_config = {
            width = 100,
          },
          prompt_title = 'Open Buffers',
        })
      end, { desc = 'Open Buffers' })
    end,
  },
}

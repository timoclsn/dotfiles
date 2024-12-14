return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'natecraddock/telescope-zf-native.nvim' },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
      { 'nvim-telescope/telescope-node-modules.nvim' },
    },
    config = function()
      local actions = require 'telescope.actions'
      local smart_opener = require 'telescope.smart_opener'
      local custom_path_display = require 'telescope.path_display'

      require('telescope').setup {
        defaults = {
          scroll_strategy = 'limit',
          mappings = {
            n = {
              ['<CR>'] = smart_opener.smart_open,
              ['<C-c>'] = actions.close,
              ['<C-v>'] = smart_opener.smart_open_split,
              ['<Tab>'] = actions.move_selection_next,
              ['<S-Tab>'] = actions.move_selection_previous,
              ['<C-s>'] = actions.toggle_selection,
              ['<C-space>'] = actions.to_fuzzy_refine,
              ['<space>'] = require('telescope.actions.layout').toggle_preview,
            },
            i = {
              ['<CR>'] = smart_opener.smart_open,
              ['<C-c>'] = actions.close,
              ['<C-v>'] = smart_opener.smart_open_split,
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-s>'] = actions.toggle_selection,
              ['<C-space>'] = actions.to_fuzzy_refine,
              ['<C-p>'] = require('telescope.actions.layout').toggle_preview,
            },
          },
          path_display = custom_path_display,
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
          ['node_modules'] = {},
        },
      }

      pcall(require('telescope').load_extension 'zf-native')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension, 'node_modules')

      local builtin = require 'telescope.builtin'

      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', require 'telescope.live_grep', { desc = '[S]earch by [G]rep' })

      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sc', builtin.git_commits, { desc = '[S]earch [C]ommits' })
      vim.keymap.set('n', '<leader>sb', builtin.git_bcommits, { desc = '[S]earch [B]lame' })
      vim.keymap.set('n', '<leader>sr', builtin.registers, { desc = '[S]earch [R]egisters' })
      vim.keymap.set('n', '<leader>sm', builtin.marks, { desc = '[S]earch [M]arks' })
      vim.keymap.set('n', '<leader>st', builtin.builtin, { desc = '[S]earch [T]elescope Pickers' })

      vim.keymap.set('n', '<leader>sw', function()
        local word = vim.fn.expand '<cword>'
        require 'telescope.live_grep' { default_text = word }
      end, { desc = '[S]earch current [W]ord' })

      vim.keymap.set('x', '<leader>sg', function()
        local visual_selection = function()
          local save_previous = vim.fn.getreg 'a'
          vim.cmd 'noau normal! "ay'
          local selection = vim.fn.getreg 'a'
          vim.fn.setreg('a', save_previous)
          return selection:gsub('\n', ' '):gsub('^%s*(.-)%s*$', '%1')
        end
        local selected_text = visual_selection()
        require 'nvim.lua.telescope.live_grep' { default_text = selected_text }
      end, { desc = '[S]earch by [G]rep' })

      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>ss', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>sq', builtin.quickfixhistory, { desc = '[S]earch [Q]uickfix History' })
      vim.keymap.set('n', '<leader>sp', '<cmd>:Telescope node_modules list<CR>', { desc = '[S]earch Node [P]ackages' })

      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<Tab>', function()
        builtin.buffers(require('telescope.themes').get_dropdown {
          sort_mru = true,
          ignore_current_buffer = true,
          only_cwd = true,
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

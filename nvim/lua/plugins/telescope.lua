return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- { -- If encountering errors, see telescope-fzf-native README for installation instructions
      --   'nvim-telescope/telescope-fzf-native.nvim',
      --
      --   -- `build` is used to run some command when the plugin is installed/updated.
      --   -- This is only run then, not every time Neovim starts up.
      --   build = 'make',
      --
      --   -- `cond` is a condition used to determine whether this plugin should be
      --   -- installed and loaded.
      --   cond = function()
      --     return vim.fn.executable 'make' == 1
      --   end,
      -- },
      { 'natecraddock/telescope-zf-native.nvim' },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
      {
        'nvim-telescope/telescope-node-modules.nvim',
      },
    },
    config = function()
      local actions = require 'telescope.actions'
      local custom_opener = require 'telescope.smart-open'
      local custom_path_display = require 'telescope.path-display'

      require('telescope').setup {
        defaults = {
          mappings = {
            n = {
              ['<CR>'] = custom_opener.smart_open,
              ['<C-c>'] = actions.close,
              ['<C-v>'] = custom_opener.smart_open_split,
              ['<Tab>'] = actions.move_selection_next,
              ['<S-Tab>'] = actions.move_selection_previous,
              ['<C-s>'] = actions.toggle_selection,
              ['<C-space>'] = actions.to_fuzzy_refine,
              ['<space>'] = require('telescope.actions.layout').toggle_preview,
            },
            i = {
              ['<CR>'] = custom_opener.smart_open,
              ['<C-c>'] = actions.close,
              ['<C-v>'] = custom_opener.smart_open_split,
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-s>'] = actions.toggle_selection,
              ['<C-space>'] = actions.to_fuzzy_refine,
              ['<C-p>'] = require('telescope.actions.layout').toggle_preview,
            },
          },
          path_display = custom_path_display,
          -- path_display = {
          --   truncate = 1,
          -- },
        },
        pickers = {
          find_files = {
            hidden = true,
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

      -- Enable Telescope extensions if they are installed
      -- pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension 'zf-native')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension, 'node_modules')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'

      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>st', builtin.builtin, { desc = '[S]earch [T]elescope Pickers' })
      vim.keymap.set('n', '<leader>sg', require 'telescope.live-grep', { desc = '[S]earch by [G]rep' })

      vim.keymap.set('n', '<leader>sw', function()
        local word = vim.fn.expand '<cword>'
        require 'telescope.live-grep' { default_text = word }
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
        require 'telescope.live-grep' { default_text = selected_text }
      end, { desc = '[S]earch by [G]rep' })

      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>sq', builtin.quickfixhistory, { desc = '[S]earch [Q]uickfix History' })
      vim.keymap.set('n', '<leader>sp', '<cmd>:Telescope node_modules list<CR>', { desc = '[S]earch Node [P]ackages' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })

      -- Shortcut for switching between open buffers
      vim.keymap.set('n', '<Tab>', function()
        builtin.buffers(require('telescope.themes').get_dropdown {
          sort_mru = true,
          sort_lastused = true,
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

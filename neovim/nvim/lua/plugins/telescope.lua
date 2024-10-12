return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      local action_state = require 'telescope.actions.state'
      local actions = require 'telescope.actions'

      local custom_actions = {}

      custom_actions.smart_open = function(prompt_bufnr)
        local picker = action_state.get_current_picker(prompt_bufnr)
        local multi_selections = picker:get_multi_selection()

        if #multi_selections > 1 then
          -- Multiple files selected, open the highlighted one and add others to buffer list
          actions.close(prompt_bufnr)
          local current_selection = action_state.get_selected_entry()
          for _, selection in ipairs(multi_selections) do
            if selection == current_selection then
              vim.cmd('edit ' .. selection.value)
            else
              vim.cmd('badd ' .. selection.value)
            end
          end
        else
          -- Single file selected (or no selection), use default behavior
          actions.select_default(prompt_bufnr)
        end
      end

      custom_actions.smart_open_split = function(prompt_bufnr)
        local picker = action_state.get_current_picker(prompt_bufnr)
        local multi_selections = picker:get_multi_selection()

        if #multi_selections > 1 then
          -- Multiple files selected, open the highlighted one on the left and others in vertical splits to the right
          actions.close(prompt_bufnr)
          local current_selection = action_state.get_selected_entry()
          vim.cmd('edit ' .. current_selection.value)
          for _, selection in ipairs(multi_selections) do
            if selection ~= current_selection then
              vim.cmd('vsplit ' .. selection.value)
            end
          end
        else
          -- Single file selected (or no selection), use default behavior
          actions.select_default(prompt_bufnr)
        end
      end

      local cwd = vim.fn.getcwd()
      local cwd_is_frontend = cwd:match 'frontend$' ~= nil

      local function custom_path_display(_, path)
        local filename = vim.fs.basename(path)

        -- Ensure the path is relative to the project directory
        local relative_path = vim.fn.fnamemodify(path, ':.')
        if vim.fn.isdirectory(path) ~= 1 then
          relative_path = vim.fn.fnamemodify(path, ':~:.:h') -- :h removes the filename
        end

        -- Remove leading './' if present
        relative_path = relative_path:gsub('^%./', '')

        -- Check if we're in the "frontend" project
        local is_frontend = cwd_is_frontend or relative_path:match '^steuerbot/frontend' ~= nil

        if is_frontend then
          -- Find "apps" or "libs" in the path
          for component in relative_path:gmatch '[^/]+' do
            if component == 'apps' or component == 'libs' then
              -- Check if there's a next component
              local next_component = relative_path:match(component .. '/([^/]+)')
              if next_component then
                filename = filename .. string.format(' (%s)', next_component)
                break -- Stop after finding the first occurrence
              end
            end
          end
        end

        if relative_path == '.' or relative_path == '' then
          return filename
        end
        return string.format('%s\t\t%s', filename, relative_path)
      end

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'TelescopeResults',
        callback = function(ctx)
          vim.api.nvim_buf_call(ctx.buf, function()
            vim.fn.matchadd('TelescopeParent', '\t\t.*$')
            vim.api.nvim_set_hl(0, 'TelescopeParent', { link = 'Comment' })
          end)
        end,
      })

      require('telescope').setup {
        defaults = {
          mappings = {
            n = {
              ['<CR>'] = custom_actions.smart_open,
              ['<C-v>'] = custom_actions.smart_open_split,
              ['<Tab>'] = actions.move_selection_next,
              ['<S-Tab>'] = actions.move_selection_previous,
              ['<C-s>'] = actions.toggle_selection,
            },
            i = {
              ['<CR>'] = custom_actions.smart_open,
              ['<C-v>'] = custom_actions.smart_open_split,
              ['<C-j>'] = require('telescope.actions').move_selection_next,
              ['<C-k>'] = require('telescope.actions').move_selection_previous,
              ['<C-s>'] = actions.toggle_selection,
            },
          },
          file_ignore_patterns = {
            '!.env',
            '.git/',
            'node_modules/',
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
                ['d'] = require('telescope.actions').delete_buffer,
              },
            },
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>sq', builtin.quickfixhistory, { desc = '[S]earch [Q]uickfix History' })

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

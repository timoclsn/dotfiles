return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'folke/snacks.nvim',
    },
    lazy = false,
    keys = {
      { '<C-e>', ':Neotree toggle<CR>', desc = 'Toggle File [e]xplorer', silent = true },
      { '<leader>e', ':Neotree reveal<CR>', desc = 'Reveal file in [e]xplorer', silent = true },
    },

    opts = {
      close_if_last_window = true,
      filesystem = {
        commands = {
          avante_add_files = function(state)
            local node = state.tree:get_node()
            local filepath = node:get_id()
            local relative_path = require('avante.utils').relative_path(filepath)

            local sidebar = require('avante').get()

            local open = sidebar:is_open()
            -- ensure avante sidebar is open
            if not open then
              require('avante.api').ask()
              sidebar = require('avante').get()
            end

            sidebar.file_selector:add_selected_file(relative_path)

            -- remove neo tree buffer
            if not open then
              sidebar.file_selector:remove_selected_file 'neo-tree filesystem [1]'
            end
          end,
        },
        window = {
          position = 'right',
          width = 60,
          mapping_options = {
            nowait = true,
          },
          mappings = {
            ['z'] = 'none',
            ['zR'] = 'close_all_nodes',
            ['C'] = 'close_all_subnodes',
            ['zM'] = 'expand_all_nodes',
            ['l'] = 'open',
            ['<C-v>'] = 'open_vsplit',
            ['h'] = 'close_node',
            ['<space>'] = { 'toggle_preview', config = { use_float = true } },
            ['P'] = 'focus_preview',
            ['<C-e>'] = 'close_window',
            ['oa'] = 'avante_add_files',
            ['<C-r>'] = {
              command = function(state)
                local node = state.tree:get_node()
                vim.fn.system('open -R ' .. vim.fn.shellescape(node.path))
              end,
              desc = 'Reveal in Finder',
            },
            ['<C-y>'] = {
              function(state)
                local node = state.tree:get_node()
                local full_path = node:get_id()

                require('utils.path_utils').copy_relative_path(full_path)
              end,
              desc = 'Copy Path to Clipboard',
            },
          },
        },
        filtered_items = {
          show_hidden_count = false,
          hide_dotfiles = false,
          hide_gitignored = false,
          never_show = {
            '.git',
            '.DS_Store',
          },
        },
      },
    },
    config = function(_, opts)
      local function on_move(data)
        require('snacks').rename.on_rename_file(data.source, data.destination)
      end
      local events = require 'neo-tree.events'
      opts.event_handlers = opts.event_handlers or {}
      vim.list_extend(opts.event_handlers, {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
      })

      require('neo-tree').setup(opts)
    end,
  },
  {
    'ThePrimeagen/harpoon',
    -- branch = 'harpoon2',
    commit = 'e76cb03', -- Custom key breaks for commits after this one
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      local harpoon = require 'harpoon'

      local function toggle_fzf(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        require('fzf-lua').fzf_exec(file_paths, {
          prompt = 'Harpoon> ',
          actions = {
            ['default'] = function(selected)
              for i, path in ipairs(file_paths) do
                if path == selected[1] then
                  harpoon_files:select(i)
                  break
                end
              end
            end,
          },
        })
      end

      -- REQUIRED
      harpoon:setup {
        settings = {
          save_on_toggle = true,
          sync_on_ui_close = true,
          key = function()
            local git_branch_reader = io.popen 'git branch --show-current'
            if git_branch_reader then
              local branch = git_branch_reader:read('*l'):match '^%s*(.-)%s*$'
              git_branch_reader:close()
              return vim.fn.getcwd() .. '-' .. branch
            end
            return vim.fn.getcwd()
          end,
        },
      }
      -- REQUIRED

      vim.keymap.set('n', '<leader>ha', function()
        harpoon:list():add()
      end, { desc = '[h]arpoon [a]dd File' })
      vim.keymap.set('n', '<leader>hl', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = '[h]arpoon [l]ist files' })

      -- Navigate to Harpoon marks 1-9
      for i = 1, 9 do
        vim.keymap.set('n', '<leader>h' .. i, function()
          harpoon:list():select(i)
        end, { desc = 'Navigate to harpoon Mark ' .. i })
      end

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set('n', '<leader>hp', function()
        harpoon:list():prev()
      end, { desc = '[h]arpoon [p]revious Buffer' })
      vim.keymap.set('n', '<leader>hn', function()
        harpoon:list():next()
      end, { desc = '[h]arpoon [n]ext Buffer' })
      vim.keymap.set('n', '<leader>hh', function()
        toggle_fzf(harpoon:list())
      end, { desc = '[h]arpoon [h]arpoon files' })
    end,
  },
  {
    'mbbill/undotree',
    config = function()
      vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = 'Toggle [u]ndotree' })
      vim.g.undotree_SplitWidth = 60
    end,
  },
}

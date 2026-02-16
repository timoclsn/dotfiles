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
    'dmtrKovalenko/fff.nvim',
    build = function()
      require('fff.download').download_or_build_binary()
    end,
    opts = { -- (optional)
      debug = {
        enabled = false, -- we expect your collaboration at least during the beta
        show_scores = false, -- to help us optimize the scoring system, feel free to share your scores!
      },
    },
    lazy = false,
    keys = {
      {
        '<leader>sf', -- try it if you didn't it is a banger keybinding for a picker
        function()
          require('fff').find_files()
        end,
        desc = 'Find files',
      },
      {
        '<leader>sg',
        function()
          require('fff').live_grep {
            grep = {
              modes = { 'fuzzy', 'plain', 'regex' },
            },
          }
        end,
        desc = 'Live grep',
      },
    },
  },
}

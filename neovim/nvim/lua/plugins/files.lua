return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
      { '<C-e>', ':Neotree toggle<CR>', desc = 'Toggle File [E]xplorer', silent = true },
      { '<leader>e', ':Neotree reveal<CR>', desc = 'Reveal file in [E]xplorer', silent = true },
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
            ['<space>'] = 'toggle_node',
            ['<C-e>'] = 'close_window',
            ['h'] = 'focus_preview',
            ['<C-r>'] = {
              command = function(state)
                local node = state.tree:get_node()
                vim.fn.system('open -R ' .. vim.fn.shellescape(node.path))
              end,
              desc = 'Reveal in Finder',
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
  },
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup {
        keymaps = {
          ['<C-h>'] = false,
          ['<C-l>'] = false,
          ['<C-k>'] = false,
          ['<C-j>'] = false,
        },
        view_options = {
          show_hidden = true,
        },
      }

      -- Open parent directory in current window
      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
    end,
  },
  {
    'ThePrimeagen/harpoon',
    -- branch = 'harpoon2',
    commit = 'e76cb03', -- Custom key breaks for commits after this one
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'

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
      end, { desc = '[H]arpoon [A]dd File' })
      vim.keymap.set('n', '<leader>hh', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = '[H]arpoon list files' })

      -- Navigate to Harpoon marks 1-9
      for i = 1, 9 do
        vim.keymap.set('n', '<C-' .. i .. '>', function()
          harpoon:list():select(i)
        end, { desc = 'Navigate to harpoon Mark ' .. i })
      end

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set('n', '<leader>hp', function()
        harpoon:list():prev()
      end, { desc = '[H]arpoon [P]revious Buffer' })
      vim.keymap.set('n', '<leader>hn', function()
        harpoon:list():next()
      end, { desc = '[H]arpoon [N]ext Buffer' })
    end,
  },
  {
    'mbbill/undotree',
    config = function()
      vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = 'Toggle [U]ndotree' })
      vim.g.undotree_SplitWidth = 60
    end,
  },
}

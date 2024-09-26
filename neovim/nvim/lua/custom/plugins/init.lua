-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  'github/copilot.vim',
  {
    'ThePrimeagen/harpoon',
    -- branch = 'harpoon2',
    commit = 'e76cb03',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'

      -- REQUIRED
      harpoon:setup {
        settings = {
          save_on_toggle = true,
          sync_on_ui_close = true,
          key = function()
            local Job = require 'plenary.job'

            local function get_os_command_output(cmd, cwd)
              if type(cmd) ~= 'table' then
                return {}
              end
              local command = table.remove(cmd, 1)
              local stderr = {}
              local stdout, ret = Job:new({
                command = command,
                args = cmd,
                cwd = cwd,
                on_stderr = function(_, data)
                  table.insert(stderr, data)
                end,
              }):sync()
              return stdout, ret, stderr
            end

            -- Use git branch name if available
            local branch = get_os_command_output({
              'git',
              'rev-parse',
              '--abbrev-ref',
              'HEAD',
            })[1]

            if branch then
              return vim.fn.getcwd() .. '-' .. branch
            else
              return vim.fn.getcwd()
            end
          end,
        },
      }
      -- REQUIRED

      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():add()
      end, { desc = 'Add file to Harpoon' })
      vim.keymap.set('n', '<C-e>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = 'Toggle Harpoon quick menu' })

      -- Navigate to Harpoon marks 1-9
      for i = 1, 9 do
        vim.keymap.set('n', '<C-' .. i .. '>', function()
          harpoon:list():select(i)
        end, { desc = 'Navigate to Harpoon mark ' .. i })
      end

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set('n', '<C-S-P>', function()
        harpoon:list():prev()
      end, { desc = 'Navigate to previous Harpoon buffer' })
      vim.keymap.set('n', '<C-S-N>', function()
        harpoon:list():next()
      end, { desc = 'Navigate to next Harpoon buffer' })
    end,
  },
  {
    'christoomey/vim-tmux-navigator',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
    },
    keys = {
      { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
      { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
    },
  },
  'mg979/vim-visual-multi',
  {
    'windwp/nvim-ts-autotag',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-ts-autotag').setup()
    end,
  },
  {
    'mbbill/undotree',
    config = function()
      vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = 'Toggle [u]ndotree' })
      vim.g.undotree_SplitWidth = 60
    end,
  },
  {
    'sindrets/diffview.nvim',
    config = function()
      require('diffview').setup {
        file_panel = {
          win_config = {
            width = 60,
          },
        },
      }

      vim.keymap.set('n', '<leader>hd', function()
        if next(require('diffview.lib').views) == nil then
          vim.cmd 'DiffviewOpen'
        else
          vim.cmd 'DiffviewClose'
        end
      end, { desc = 'git [d]iff against index' })
    end,
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
  { 'tpope/vim-fugitive' },
}

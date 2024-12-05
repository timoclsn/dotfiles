return {
  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>gg', '<cmd>Git<cr>', { desc = 'Open [G]it' })
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      current_line_blame = true,

      on_attach = function()
        local gitsigns = require 'gitsigns'
        vim.keymap.set('n', '<leader>gp', gitsigns.preview_hunk, { desc = '[G]it [P]review hunk' })
        vim.keymap.set('n', '<leader>gs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
        vim.keymap.set('n', '<leader>gr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
        vim.keymap.set('n', '<leader>gS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
        vim.keymap.set('n', '<leader>gu', gitsigns.undo_stage_hunk, { desc = 'git [u]ndo stage hunk' })
        vim.keymap.set('n', '<leader>gR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
      end,
    },
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

      vim.keymap.set('n', '<leader>gd', function()
        if next(require('diffview.lib').views) == nil then
          vim.cmd 'DiffviewOpen'
        else
          vim.cmd 'DiffviewClose'
        end
      end, { desc = '[G]it [d]iff against index' })

      vim.keymap.set('n', '<leader>gD', function()
        if next(require('diffview.lib').views) == nil then
          vim.cmd 'DiffviewOpen develop'
        else
          vim.cmd 'DiffviewClose'
        end
      end, { desc = '[G]it diff against [D]evelop' })

      vim.keymap.set('n', '<leader>gM', function()
        if next(require('diffview.lib').views) == nil then
          vim.cmd 'DiffviewOpen main'
        else
          vim.cmd 'DiffviewClose'
        end
      end, { desc = '[G]it diff against [M]ain' })
    end,
  },
}

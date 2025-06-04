return {
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
        vim.keymap.set('n', '<leader>gp', gitsigns.preview_hunk, { desc = '[g]it [p]review hunk' })
        vim.keymap.set('n', '<leader>gi', gitsigns.preview_hunk_inline, { desc = '[g]it preview hunk [i]nline' })
        vim.keymap.set('n', '<leader>gs', gitsigns.stage_hunk, { desc = '[g]it toggle [s]tage hunk' })
        vim.keymap.set('n', '<leader>gr', gitsigns.reset_hunk, { desc = '[g]it [r]eset hunk' })
        vim.keymap.set('n', '<leader>gS', gitsigns.stage_buffer, { desc = '[g]it [S]tage buffer' })
        vim.keymap.set('n', '<leader>gR', gitsigns.reset_buffer, { desc = '[g]it [R]eset buffer' })
        vim.keymap.set('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end)
        vim.keymap.set('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end)
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
      end, { desc = '[g]it [d]iff against index' })

      vim.keymap.set('n', '<leader>gD', function()
        if next(require('diffview.lib').views) == nil then
          vim.cmd 'DiffviewOpen develop'
        else
          vim.cmd 'DiffviewClose'
        end
      end, { desc = '[g]it diff against [D]evelop' })

      vim.keymap.set('n', '<leader>gM', function()
        if next(require('diffview.lib').views) == nil then
          vim.cmd 'DiffviewOpen main'
        else
          vim.cmd 'DiffviewClose'
        end
      end, { desc = '[g]it diff against [M]ain' })
      vim.keymap.set('n', '<leader>gh', function()
        if next(require('diffview.lib').views) == nil then
          vim.cmd 'DiffviewOpen HEAD~1'
        else
          vim.cmd 'DiffviewClose'
        end
      end, { desc = '[g]it diff against [h]ead - 1 (last two commits)' })
      vim.keymap.set('n', '<leader>gf', function()
        if next(require('diffview.lib').views) == nil then
          vim.cmd 'DiffviewFileHistory %'
        else
          vim.cmd 'DiffviewClose'
        end
      end, { desc = '[g]it [f]ile history' })
    end,
  },
}

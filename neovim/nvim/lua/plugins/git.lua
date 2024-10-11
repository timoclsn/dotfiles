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
        vim.keymap.set('n', '<leader>gp', require('gitsigns').preview_hunk, { desc = '[G]it [P]review hunk' })
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
      end, { desc = '[G]it [D]iff against index' })
    end,
  },
}

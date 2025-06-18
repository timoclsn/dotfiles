return {
  {
    'NMAC427/guess-indent.nvim',
    opts = {},
  },
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('todo-comments').setup()

      vim.keymap.set('n', '<leader>sy', '<cmd>:TodoQuickFix<CR>', { desc = '[s]earch [y] todo comments' })
    end,
  },
  {
    'jake-stewart/multicursor.nvim',
    config = function()
      local mc = require 'multicursor-nvim'
      mc.setup()

      local set = vim.keymap.set

      set({ 'n', 'x' }, '∂', function()
        mc.matchAddCursor(1)
      end)

      set('x', 'S', mc.splitCursors)

      mc.addKeymapLayer(function(layerSet)
        layerSet('n', '<esc>', function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)
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
  {
    'brenoprata10/nvim-highlight-colors',
    opts = {
      render = 'virtual',
      enable_tailwind = true,
    },
  },
  {
    'axelvc/template-string.nvim',
    config = function()
      require('template-string').setup {
        remove_template_string = true,
      }
    end,
  },
  {
    'nat-418/boole.nvim',
    opts = {
      mappings = {
        increment = '<C-a>',
        decrement = '<C-x>',
      },
      additions = {
        { 'production', 'development', 'test' },
        { 'prod', 'staging', 'develop', 'test', 'test2', 'test3', 'test4' },
        { 'let', 'const' },
        { 'start', 'end' },
        { 'import', 'export' },
        { 'before', 'after' },
        { 'plus', 'minus' },
        { 'left', 'right' },
        { 'FIX', 'TODO', 'HACK', 'WARN', 'PERF', 'NOTE', 'TEST' },
      },
    },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {},
  },
  -- Provides syntax highlighting for the ghostty config file
  -- No additional dependencies required, Zilchmasta was kind enough to let me
  -- know about this in discord
  -- https://discord.com/channels/1005603569187160125/1300462095946485790/1300534513788653630
  {
    'ghostty',
    dir = '/Applications/Ghostty.app/Contents/Resources/vim/vimfiles/',
    lazy = false,
  },
  {
    'jinh0/eyeliner.nvim',
    opts = {
      highlight_on_key = true,
    },
  },
}

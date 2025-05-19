return {
  {
    'NMAC427/guess-indent.nvim',
    opts = {},
  },
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 500,
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Document existing key chains
      spec = {
        { '<leader>d', group = '[d]ocument' },
        { '<leader>s', group = '[s]earch' },
        { '<leader>w', group = '[w]orkspace' },
        { '<leader>t', group = '[t]oggle' },
        { '<leader>h', group = '[h]arpoon' },
        { '<leader>g', group = '[g]it' },
        { '<leader>a', group = '[a]i' },
        { '<leader>y', group = '[y]ank' },
        { '<leader>p', group = '[p]aste' },
        { '<leader>q', group = '[q]uickfix list' },
        { '<leader>b', group = '[b]uffer' },
        { '<leader>i', group = '[i]mports' },
      },
    },
  },
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('todo-comments').setup()

      vim.keymap.set('n', '<leader>sy', '<cmd>:TodoTelescope<CR>', { desc = '[s]earch [y] todo comments' })
    end,
  },
  {
    'mg979/vim-visual-multi',
    init = function()
      vim.g.VM_maps = {
        ['Find Under'] = '∂', -- Alt + d
        ['Find Subword Under'] = '∂', -- Alt + d
      }
    end,
  },
  {
    'windwp/nvim-ts-autotag',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-ts-autotag').setup()
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
  {
    'folke/ts-comments.nvim',
    opts = {},
    event = 'VeryLazy',
    enabled = vim.fn.has 'nvim-0.10.0' == 1,
  },
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      {
        '<leader>f',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash',
      },
      {
        '<leader>F',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash Treesitter',
      },
      {
        'r',
        mode = 'o',
        function()
          require('flash').remote()
        end,
        desc = 'Remote Flash',
      },
    },
  },
}

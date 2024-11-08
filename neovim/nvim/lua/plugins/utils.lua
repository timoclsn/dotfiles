return {
  {
    'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  },
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default whick-key.nvim defined Nerd Font icons, otherwise define a string table
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
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = '[H]arpoon' },
        { '<leader>g', group = '[G]it' },
        { '<leader>a', group = '[A]I' },
        { '<leader>q', group = '[Q]uickfix list' },
      },
    },
  },
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      require('mini.move').setup {
        mappings = {
          -- Move visual selection in Visual mode.
          right = '@', -- Alt + l
          left = 'ª', -- Alt + h
          down = 'º', -- Alt + j
          up = '∆', -- Alt + k

          -- Move current line in Normal mode
          line_left = 'ª', -- Alt + h
          line_right = '@', -- Alt + l
          line_down = 'º', -- Alt + j
          line_up = '∆', -- Alt + k
        },
      }

      -- Startscreen
      require('mini.starter').setup {
        items = {
          require('mini.starter').sections.recent_files(10, true, true),
          require('mini.starter').sections.builtin_actions(),
        },
        footer = 'Happy coding!',
      }

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l(%L):%-2v'
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_lsp = function()
        return ''
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_diagnostics = function()
        return ''
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_diff = function()
        return ''
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_fileinfo = function()
        local filetype = vim.bo.filetype
        local icon = require('mini.icons').get('filetype', filetype)
        return icon .. ' ' .. filetype
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_searchcount = function()
        return ''
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_filename = function()
        local path = vim.fn.expand '%:p' -- Get full path of current file
        local filename = vim.fn.expand '%:t'
        local relative_path = vim.fn.fnamemodify(path, ':~:.:h') -- Get directory path relative to current directory

        -- Check if we're in the "frontend" project
        local is_frontend = vim.fn.getcwd():match 'frontend$' ~= nil or vim.fn.getcwd():match 'frontend%-.*$' ~= nil

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
        else
          -- Check if the filename is "page.tsx" or "route.ts"
          if filename == 'page.tsx' or filename == 'route.ts' then
            -- Extract the directory name
            local directory_name = relative_path:match '([^/]+)$'
            if directory_name then
              -- Strip parentheses if they exist
              if directory_name:match '^%b()$' then
                directory_name = directory_name:sub(2, -2)
              end

              -- Check for square brackets and add the next directory name one level up
              if directory_name:match '^%b[]$' then
                local parent_directory = relative_path:match '([^/]+)/[^/]+$'
                if parent_directory then
                  directory_name = parent_directory .. '/' .. directory_name
                end
              end

              filename = filename .. string.format(' (%s)', directory_name)
            end
          end
        end

        -- Get file flags (modified, readonly, etc.)
        local flags = ''
        if vim.bo.modified then
          flags = flags .. ' [+]'
        end
        if vim.bo.modifiable == false or vim.bo.readonly == true then
          flags = flags .. ' [-]'
        end
        if vim.bo.filetype == 'help' then
          flags = flags .. ' [help]'
        end

        -- Construct the display string
        local display = filename .. flags

        -- Add the path if it's not just '.'
        if relative_path ~= '.' then
          display = display .. ' | ' .. relative_path
        end

        return display
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    -- Optional dependency
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      require('nvim-autopairs').setup {}
      -- If you want to automatically add `(` after selecting a function or method
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      local cmp = require 'cmp'
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },
  {
    'mg979/vim-visual-multi',
  },
  {
    'windwp/nvim-ts-autotag',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-ts-autotag').setup()
    end,
  },
  {
    'folke/ts-comments.nvim',
    opts = {},
    event = 'VeryLazy',
    enabled = vim.fn.has 'nvim-0.10.0' == 1,
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
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      -- Enabled
      bufdelete = { enabled = true },
      gitbrowse = { enabled = true },
      rename = { enabled = true },
      words = { enabled = true },
      bigfile = { enabled = true },
      notifier = { enabled = true, style = 'minimal' },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },

      -- Disabled
      git = { enabled = false },
      lazygit = { enabled = false },
      notify = { enabled = false },
      terminal = { enabled = false },
      toggle = { enabled = false },
      win = { enabled = false },
      debug = { enabled = false },
    },
    keys = {
      {
        '<leader>wn',
        function()
          require('snacks').notifier.show_history()
        end,
        desc = '[W]orkspace [N]otifications',
      },
      {
        '<leader>dd',
        function()
          require('snacks').bufdelete()
        end,
        desc = '[D]ocument [D]elete buffer',
      },
      {
        '<leader>go',
        function()
          require('snacks').gitbrowse()
        end,
        desc = '[G]it [O]pen',
      },
      {
        'ä',
        function()
          require('snacks').words.jump(vim.v.count1)
        end,
        desc = 'Next Reference',
      },
      {
        'ö',
        function()
          require('snacks').words.jump(-vim.v.count1)
        end,
        desc = 'Previous Reference',
      },
    },
    config = function(_, opts)
      require('snacks').setup(opts)
    end,
  },
}

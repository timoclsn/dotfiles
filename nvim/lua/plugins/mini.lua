return {
  {
    'echasnovski/mini.nvim',
    depedencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      require('mini.extra').setup()

      -- ============================================
      -- Text editing modules
      -- ============================================

      require('mini.ai').setup {
        custom_textobjects = {
          F = require('mini.ai').gen_spec.treesitter {
            a = '@function.outer',
            i = '@function.inner',
          },
          o = require('mini.ai').gen_spec.treesitter {
            a = { '@conditional.outer', '@loop.outer' },
            i = { '@conditional.inner', '@loop.inner' },
          },
          B = require('mini.extra').gen_ai_spec.buffer(),
        },
      }

      require('mini.comment').setup()

      require('mini.move').setup {
        mappings = {
          -- Move current line in Normal mode
          line_down = 'º', -- Alt + j
          line_up = '∆', -- Alt + k
        },
      }

      require('mini.operators').setup()

      require('mini.pairs').setup()

      require('mini.splitjoin').setup()

      require('mini.surround').setup()

      -- ============================================
      -- General workflow modules
      -- ============================================

      require('mini.bracketed').setup()

      require('mini.files').setup()
      local open_mini_files = function()
        if not MiniFiles.close() then
          MiniFiles.open(vim.api.nvim_buf_get_name(0))
          MiniFiles.reveal_cwd()
        end
      end
      vim.keymap.set('n', '-', open_mini_files, { desc = 'Open mini file browser' })

      -- ============================================
      -- Appearance modules
      -- ============================================

      require('mini.icons').setup()
      require('mini.icons').mock_nvim_web_devicons()

      local function footer()
        local cwd = vim.fn.getcwd()
        local current_dir = vim.fn.fnamemodify(cwd, ':t')
        local parent_dir = vim.fn.fnamemodify(cwd, ':h:t')

        if parent_dir == 'steuerbot' then
          return 'Working on Steuerbot [' .. current_dir .. '] 🤖'
        elseif parent_dir == 'taxfix' then
          return 'Working on Taxfix [' .. current_dir .. '] %'
        else
          return 'Happy coding [' .. current_dir .. ']!'
        end
      end

      require('mini.starter').setup {
        items = {
          require('mini.starter').sections.recent_files(10, true, true),
          require('mini.starter').sections.builtin_actions(),
        },
        footer = footer(),
      }

      -- Statusline
      local function cusom_location()
        return '%2l[%L]:%-2v'
      end

      local path_formatter = require 'utils.path_formatter'

      local function custom_filename()
        if vim.bo.buftype == 'terminal' then
          return '%t'
        end

        local path = vim.fn.expand '%:p'
        local formatted = path_formatter(path)

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
        local display = formatted.filename .. flags

        -- Add the path if it's not just '.'
        if formatted.relative_path ~= '.' then
          display = display .. ' -> ' .. formatted.relative_path
        end

        return display
      end

      local force_truncate = 1000

      require('mini.statusline').setup {
        content = {
          use_icons = vim.g.have_nerd_font,
          active = function()
            local mode, mode_hl = MiniStatusline.section_mode { trunc_width = 120 }
            local git = MiniStatusline.section_git { trunc_width = 40 }
            -- local diff = MiniStatusline.section_diff { trunc_width = 75 }
            local diagnostics = MiniStatusline.section_diagnostics { trunc_width = 75 }
            -- local lsp = MiniStatusline.section_lsp { trunc_width = 75 }
            local filename = custom_filename()
            local fileinfo = MiniStatusline.section_fileinfo { trunc_width = force_truncate }
            local location = cusom_location()
            -- local search = MiniStatusline.section_searchcount { trunc_width = 75 }

            return MiniStatusline.combine_groups {
              { hl = mode_hl, strings = { mode } },
              {
                hl = 'MiniStatuslineDevinfo',
                strings = {
                  git,
                  -- diff,
                  diagnostics,
                  -- lsp,
                },
              },
              '%<', -- Mark general truncate point
              { hl = 'MiniStatuslineFilename', strings = { filename } },
              '%=', -- End left alignment
              { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
              {
                hl = mode_hl,
                strings = {
                  -- search,
                  location,
                },
              },
            }
          end,
        },
      }
    end,
  },
}

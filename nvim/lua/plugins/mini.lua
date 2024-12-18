return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      require('mini.pairs').setup()

      require('mini.bracketed').setup()

      require('mini.ai').setup {
        custom_textobjects = {
          F = require('mini.ai').gen_spec.treesitter { a = '@function.outer', i = '@function.inner' },
        },
      }

      require('mini.surround').setup()

      require('mini.operators').setup()

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

      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l(%L):%-2v'
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_lsp = function()
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

      local path_formatter = require 'utils.path_formatter'

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_filename = function()
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
    end,
  },
}

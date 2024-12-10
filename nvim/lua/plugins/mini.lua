return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      require('mini.pairs').setup()

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
    end,
  },
}

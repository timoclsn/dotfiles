local conf = require('telescope.config').values
local finders = require 'telescope.finders'
local make_entry = require 'telescope.make_entry'
local pickers = require 'telescope.pickers'

--- @diagnostic disable-next-line: deprecated
local flatten = vim.tbl_flatten

return function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()
  opts.default_text = opts.default_text or ''
  opts.shortcuts = opts.shortcuts
    or {
      ['m'] = { '**/{mobile,mobile-app}/**' },
      ['w'] = { '**/{web,web-app}/**', '!**/.next/**', '!**/node_modules/**' },
      ['s'] = { '**/shared/**' },
      ['t'] = { '*.ts' },
      ['r'] = { '*.tsx' },
    }
  opts.pattern = opts.pattern or '%s'

  local custom_grep = finders.new_async_job {
    command_generator = function(prompt)
      if not prompt or prompt == '' then
        return nil
      end

      local prompt_split = vim.split(prompt, '  ')

      local args = { 'rg' }
      if prompt_split[1] then
        table.insert(args, '-F')
        table.insert(args, '-e')
        table.insert(args, vim.trim(prompt_split[1]))
      end

      if prompt_split[2] then
        local patterns
        if opts.shortcuts[prompt_split[2]] then
          patterns = opts.shortcuts[prompt_split[2]]
        else
          patterns = { prompt_split[2] }
        end

        for _, pattern in ipairs(patterns) do
          table.insert(args, '-g')
          table.insert(args, string.format(opts.pattern, pattern))
        end
      end

      return flatten {
        args,
        { '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case' },
      }
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  }

  local picker = pickers.new(opts, {
    debounce = 100,
    prompt_title = 'Live Grep',
    finder = custom_grep,
    previewer = conf.grep_previewer(opts),
    sorter = require('telescope.sorters').empty(),
  })

  picker:find()
end

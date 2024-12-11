local M = {}

local cwd = vim.fn.getcwd()
local cwd_is_frontend = cwd:match 'frontend$' ~= nil or cwd:match 'frontend%-.*$' ~= nil

M.custom_path_display = function(_, path)
  local filename = vim.fs.basename(path)

  -- Ensure the path is relative to the project directory
  local relative_path = vim.fn.fnamemodify(path, ':.')
  if vim.fn.isdirectory(path) ~= 1 then
    relative_path = vim.fn.fnamemodify(path, ':~:.:h') -- :h removes the filename
  end

  -- Remove leading './' if present
  relative_path = relative_path:gsub('^%./', '')

  -- Check if we're in the "frontend" project
  local is_frontend = cwd_is_frontend or relative_path:match '^steuerbot/frontend$' ~= nil or relative_path:match '^steuerbot/frontend%-.*' ~= nil

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

  if relative_path == '.' or relative_path == '' then
    return filename
  end
  return string.format('%s\t\t%s', filename, relative_path)
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'TelescopeResults',
  callback = function(ctx)
    vim.api.nvim_buf_call(ctx.buf, function()
      vim.fn.matchadd('TelescopeParent', '\t\t.*$')
      vim.api.nvim_set_hl(0, 'TelescopeParent', { link = 'Comment' })
    end)
  end,
})

return M

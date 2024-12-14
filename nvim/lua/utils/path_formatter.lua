local M = {}

-- Helper function to check if we're in a frontend project
local function is_frontend_project(cwd, relative_path)
  return cwd:match 'frontend$' ~= nil
    or cwd:match 'frontend%-.*$' ~= nil
    or relative_path:match '^steuerbot/frontend$' ~= nil
    or relative_path:match '^steuerbot/frontend%-.*' ~= nil
end

local function is_nextjs_project(filename)
  return filename == 'page.tsx' or filename == 'route.ts'
end

-- Helper function to format frontend path
local function format_frontend_path(relative_path, filename)
  for component in relative_path:gmatch '[^/]+' do
    if component == 'apps' or component == 'libs' then
      local next_component = relative_path:match(component .. '/([^/]+)')
      if next_component then
        return filename .. string.format(' (%s)', next_component)
      end
    end
  end
  return filename
end

-- Helper function to format route/page path
local function format_route_path(relative_path, filename)
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

    return filename .. string.format(' (%s)', directory_name)
  end
  return filename
end

-- Main formatting function
function M.format_path(path, options)
  options = options or {}
  local cwd = options.cwd or vim.fn.getcwd()

  local filename = vim.fs.basename(path)
  local relative_path = vim.fn.fnamemodify(path, ':~:.:h')
  -- Remove leading './' if present
  relative_path = relative_path:gsub('^%./', '')

  local is_frontend = is_frontend_project(cwd, relative_path)
  local is_nextjs = is_nextjs_project(filename)

  local formatted_filename = filename
  if is_frontend then
    formatted_filename = format_frontend_path(relative_path, filename)
  elseif is_nextjs then
    formatted_filename = format_route_path(relative_path, filename)
  end

  return {
    filename = formatted_filename,
    relative_path = relative_path,
  }
end

return M

local M = {}

-- Path patterns for frontend projects
local frontend_patterns = {
  '.*/steuerbot/frontend/.*',
  '.*/steuerbot/frontend%-[^/]+/.*',
}

-- Filenames that indicate Next.js pages/routes
local nextjs_files = {
  'page.tsx',
  'route.ts',
}

-- Helper function to check if we're in a frontend project
local function is_frontend_project(full_path)
  for _, pattern in ipairs(frontend_patterns) do
    local match = full_path:match(pattern)
    if match then
      return true
    end
  end
  return false
end

local function is_nextjs_project(filename)
  for _, file in ipairs(nextjs_files) do
    if filename == file then
      return true
    end
  end
  return false
end

-- Helper function to format frontend path
local function format_frontend_path(full_path, filename)
  for component in full_path:gmatch '[^/]+' do
    if component == 'apps' or component == 'libs' then
      local next_component = full_path:match(component .. '/([^/]+)')
      if next_component then
        return filename .. string.format(' (%s)', next_component)
      end
    end
  end
  return filename
end

-- Helper function to format route/page path
local function format_route_path(full_path, filename)
  local directory_name = full_path:match '([^/]+)/[^/]+$'
  if directory_name then
    -- Strip parentheses if they exist
    if directory_name:match '^%b()$' then
      directory_name = directory_name:sub(2, -2)
    end

    -- Check for square brackets and add the next directory name one level up
    if directory_name:match '^%b[]$' then
      local parent_directory = full_path:match '([^/]+)/[^/]+/[^/]+$'
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

  local filename = vim.fs.basename(path)
  local full_path = vim.fn.fnamemodify(path, ':p')
  local relative_path = vim.fn.fnamemodify(path, ':~:.:h')

  -- Remove trailing slash if present
  full_path = full_path:gsub('/$', '')
  -- Remove leading './' if present
  relative_path = relative_path:gsub('^%./', '')

  local is_frontend = is_frontend_project(full_path)
  local is_nextjs = is_nextjs_project(filename)

  local formatted_filename = filename
  if is_frontend then
    formatted_filename = format_frontend_path(full_path, filename)
  elseif is_nextjs then
    formatted_filename = format_route_path(full_path, filename)
  end

  return {
    filename = formatted_filename,
    relative_path = relative_path,
  }
end

return M

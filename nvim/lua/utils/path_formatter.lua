local M = {}

-- Cache commonly used Vim and Lua functions
local basename = vim.fs.basename
local match = string.match
local sub = string.sub

-- Define patterns to identify frontend project paths
local frontend_patterns = {
  'steuerbot/frontend/',
  'steuerbot/frontend%-[^/]+/',
}

-- Define patterns to identify Next.js route files
local nextjs_patterns = {
  'page.tsx$',
  'route.ts$',
}

-- Patterns for extracting directory information
local apps_pattern = '/apps/([^/]+)'
local libs_pattern = '/libs/([^/]+)'
local directory_pattern = '([^/]+)/[^/]+$'
local parent_directory_pattern = '([^/]+)/[^/]+/[^/]+$'

-- Check if a path matches any of the given patterns
local function match_patterns(path, patterns)
  for pattern_index = 1, #patterns do
    if string.find(path, patterns[pattern_index]) then
      return true
    end
  end
  return false
end

-- Format path for frontend projects by extracting the app or lib name
local function format_frontend_path(full_path, filename)
  -- Check if path is under /apps/ directory
  local component_name = match(full_path, apps_pattern)
  if component_name then
    return filename .. ' (' .. component_name .. ')'
  end

  -- Check if path is under /libs/ directory
  component_name = match(full_path, libs_pattern)
  if component_name then
    return filename .. ' (' .. component_name .. ')'
  end

  return filename
end

-- Format path for Next.js routes by extracting the route information
local function format_route_path(full_path, filename)
  -- Extract the immediate parent directory name
  local directory_name = match(full_path, directory_pattern)
  if not directory_name then
    return filename
  end

  -- Handle special directory naming patterns
  local first_character = sub(directory_name, 1, 1)
  local last_character = sub(directory_name, -1)

  -- Remove parentheses if present
  if first_character == '(' and last_character == ')' then
    directory_name = sub(directory_name, 2, -2)
  -- For dynamic routes (in square brackets), include the parent directory name
  elseif first_character == '[' and last_character == ']' then
    local parent_directory = match(full_path, parent_directory_pattern)
    if parent_directory then
      directory_name = parent_directory .. '/' .. directory_name
    end
  end

  return filename .. ' (' .. directory_name .. ')'
end

-- Main function to format file paths based on their location and type
function M.format_path(path)
  local full_path = vim.fn.fnamemodify(path, ':p')
  local filename = basename(full_path)

  -- Handle empty paths
  if full_path == '' then
    return { filename = '', relative_path = '' }
  end

  local relative_path = vim.fn.fnamemodify(path, ':~:.:h')

  -- Clean up path formatting
  if sub(full_path, -1) == '/' then
    full_path = sub(full_path, 1, -2)
  end

  if sub(relative_path, 1, 2) == './' then
    relative_path = sub(relative_path, 3)
  end

  -- Determine the appropriate formatting based on path type
  local formatted_filename
  if match_patterns(full_path, frontend_patterns) then
    formatted_filename = format_frontend_path(full_path, filename)
  elseif match_patterns(full_path, nextjs_patterns) then
    formatted_filename = format_route_path(full_path, filename)
  else
    formatted_filename = filename
  end

  return {
    filename = formatted_filename,
    relative_path = relative_path,
  }
end

return M

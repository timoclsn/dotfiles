local frontend_patterns = {
  'steuerbot/frontend/',
  'steuerbot/frontend%-[^/]+/',
}

local mobile_app_patterns = {
  'taxfix/mobile%-app/',
  'taxfix/mobile%-app%-[^/]+/',
}

local nextjs_patterns = {
  'page.tsx$',
  'route.ts$',
}

-- Check if a path matches any of the given patterns
local function match_patterns(path, patterns)
  for _, pattern in ipairs(patterns) do
    if path:match(pattern) then
      return true
    end
  end
  return false
end

local function format_frontend_path(full_path, filename)
  -- Check if path is under /apps/ directory
  local component_name = full_path:match '/apps/([^/]+)'
  if component_name then
    return filename .. ' [' .. component_name .. ']'
  end

  -- Check if path is under /libs/ directory
  component_name = full_path:match '/libs/([^/]+)'
  if component_name then
    return filename .. ' [' .. component_name .. ']'
  end

  return filename
end

local function format_mobile_app_path(full_path, filename)
  local package_name = full_path:match '/packages/([^/]+)'
  if package_name then
    return filename .. ' [' .. package_name .. ']'
  end

  local adapter_name = full_path:match '/modules/mobile%-app%-legacy/src/domain%-adapters/([^/]+)'
  if adapter_name then
    return filename .. ' [' .. adapter_name .. ']'
  end

  return filename
end

-- Format path for Next.js routes by extracting the route information
local function format_nextjs_path(full_path, filename)
  -- Extract the immediate parent directory name
  local directory_name = full_path:match '([^/]+)/[^/]+$'
  if not directory_name then
    return filename
  end

  -- Handle special directory naming patterns
  local first_character = string.sub(directory_name, 1, 1)
  local last_character = string.sub(directory_name, -1)

  -- Remove parentheses if present
  if first_character == '(' and last_character == ')' then
    directory_name = string.sub(directory_name, 2, -2)
  -- For dynamic routes (in square brackets), include the parent directory name
  elseif first_character == '[' and last_character == ']' then
    local parent_directory = full_path:match '([^/]+)/[^/]+/[^/]+$'
    if parent_directory then
      directory_name = parent_directory .. '/' .. directory_name
    end
  end

  return filename .. ' [' .. directory_name .. ']'
end

-- Main function to format file paths based on their location and type
local function format_path(path)
  local full_path = vim.fn.fnamemodify(path, ':p')
  local filename = vim.fs.basename(full_path)

  -- Handle empty paths
  if full_path == '' then
    return { filename = '', relative_path = '' }
  end

  local relative_path = vim.fn.fnamemodify(path, ':~:.:h')

  -- Clean up path formatting
  -- Remove trailing slashes from full path
  if string.sub(full_path, -1) == '/' then
    full_path = string.sub(full_path, 1, -2)
  end

  -- Remove leading './' from relative path
  if string.sub(relative_path, 1, 2) == './' then
    relative_path = string.sub(relative_path, 3)
  end

  -- Determine the appropriate formatting based on path type
  local formatted_filename
  if match_patterns(full_path, frontend_patterns) then
    formatted_filename = format_frontend_path(full_path, filename)
  elseif match_patterns(full_path, mobile_app_patterns) then
    formatted_filename = format_mobile_app_path(full_path, filename)
  elseif match_patterns(full_path, nextjs_patterns) then
    formatted_filename = format_nextjs_path(full_path, filename)
  else
    formatted_filename = filename
  end

  return {
    filename = formatted_filename,
    relative_path = relative_path,
  }
end

return format_path

local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local entry_display = require 'telescope.pickers.entry_display'

-- Function to read and parse JSON file
local function read_json_file(filepath)
  local file = io.open(filepath, 'r')
  if not file then
    return nil, string.format('File not found: %s', filepath)
  end

  local content = file:read '*all'
  file:close()

  local ok, parsed = pcall(vim.json.decode, content)
  if not ok then
    return nil, string.format('Failed to parse JSON file: %s', filepath)
  end

  return parsed
end

-- Helper function to validate URL
local function is_valid_url(url)
  if not url then
    return false
  end

  local pattern = '^https?://' -- Protocol (http or https)
    .. '([%w%.%-]+)' -- Domain name

  return url:match(pattern) ~= nil
end

local node_modules_path = vim.uv.cwd() .. '/node_modules/'

-- Helper function to get repo URL from package.json
local function get_repo_info(pkg_name)
  local pkg_json_path = node_modules_path .. pkg_name .. '/package.json'
  local pkg_data = read_json_file(pkg_json_path)

  local npm_url = string.format('https://www.npmjs.com/package/%s', pkg_name)

  if not pkg_data then
    return npm_url, ''
  end

  local pkg_description = pkg_data and pkg_data.description or ''

  if pkg_data.homepage then
    local homepage = pkg_data.homepage
    if is_valid_url(homepage) then
      return homepage, pkg_description
    end
  end

  if pkg_data.repository then
    local repo_url = type(pkg_data.repository) == 'string' and pkg_data.repository or pkg_data.repository.url
    if repo_url then
      -- Clean up repository URL
      repo_url = repo_url:gsub('git%+', '')
      repo_url = repo_url:gsub('git://', 'https://')
      repo_url = repo_url:gsub('%.git$', '')
      if is_valid_url(repo_url) then
        return repo_url, pkg_description
      end
    end
  end

  return npm_url, pkg_description
end

-- Function to extract dependencies and their repository URLs
local function get_dependencies(package_json)
  local deps = {}
  local devDeps = {}

  -- Regular dependencies
  if package_json.dependencies then
    for name, version in pairs(package_json.dependencies) do
      local repo_url, repo_despription = get_repo_info(name)
      table.insert(deps, {
        name = name,
        version = version,
        type = 'dependency',
        repo_url = repo_url,
        description = repo_despription,
      })
    end
  end

  -- Dev dependencies
  if package_json.devDependencies then
    for name, version in pairs(package_json.devDependencies) do
      local repo_url, repo_despription = get_repo_info(name)
      table.insert(devDeps, {
        name = name,
        version = version,
        type = 'devDependency',
        repo_url = repo_url,
        description = repo_despription,
      })
    end
  end

  -- Sort both arrays alphabetically  reversed by name
  table.sort(deps, function(a, b)
    return a.name > b.name
  end)
  table.sort(devDeps, function(a, b)
    return a.name > b.name
  end)

  -- Combine the sorted arrays
  for _, dep in ipairs(deps) do
    table.insert(devDeps, dep)
  end

  return devDeps
end

-- Function to open URL in browser
local function open_url(url)
  vim.fn.system('open ' .. url)
end

local function jump_to_package_in_package_json(package_name)
  -- Open package.json
  vim.cmd 'edit package.json'

  -- Get the content of the file
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- Look for the package in dependencies and devDependencies
  for i, line in ipairs(lines) do
    -- Check if line contains the package name as a key
    if line:match('"' .. package_name .. '"') then
      -- Schedule the cursor movement and centering to happen after the buffer is loaded
      vim.schedule(function()
        -- Move cursor to that line
        vim.api.nvim_win_set_cursor(0, { i, 0 })
        -- Center the line in the window
        vim.cmd 'normal! zz'
      end)
      break
    end
  end
end

-- Main function to list node modules
return function(opts)
  opts = opts or {}

  -- Read package.json
  local package_json = read_json_file 'package.json'

  if not package_json then
    vim.notify('No package.json found', vim.log.levels.ERROR)
    return
  end

  -- Get dependencies
  local deps = get_dependencies(package_json)

  -- Calculate max lengths for columns
  local max_lengths = {
    picker = 200,
    name = 0,
    version = 0,
    type = 0,
  }

  for _, dep in ipairs(deps) do
    max_lengths.name = math.max(max_lengths.name, #dep.name)
    max_lengths.version = math.max(max_lengths.version, #dep.version)
    max_lengths.type = math.max(max_lengths.type, #dep.type)
  end

  -- Create entry maker with dynamic widths
  local displayer = entry_display.create {
    separator = '  ',
    items = {
      { width = max_lengths.name }, -- name
      { width = max_lengths.version }, -- version
      { width = max_lengths.type }, -- type
      { remaining = true }, -- description
    },
  }

  local make_display = function(entry)
    local desciption = entry.description
    local desciptionMaxLen = max_lengths.picker - max_lengths.name - max_lengths.version - max_lengths.type - 10 -- 3 * 2 spaces + border?
    if #desciption > desciptionMaxLen then
      desciption = desciption:sub(1, desciptionMaxLen - 3) .. '...'
    end
    return displayer {
      entry.name,
      entry.version,
      entry.type,
      desciption,
    }
  end

  local picker = pickers.new(opts, {
    prompt_title = 'Installed Packages',
    finder = finders.new_table {
      results = deps,
      entry_maker = function(entry)
        return {
          value = entry,
          display = make_display,
          ordinal = entry.name .. ' ' .. entry.version,
          name = entry.name,
          version = entry.version,
          type = entry.type,
          repo_url = entry.repo_url,
          description = entry.description,
        }
      end,
    },
    previewer = false,
    layout_config = {
      width = max_lengths.picker,
    },
    sorter = require('telescope.sorters').get_generic_fuzzy_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      -- Jump to package in package.json on Enter
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        jump_to_package_in_package_json(selection.value.name)
      end)

      -- Open URL on Ctrl-o
      map('i', '<C-o>', function()
        local selection = action_state.get_selected_entry()
        open_url(selection.repo_url)
        vim.notify('Opened: ' .. selection.repo_url, vim.log.levels.INFO)
        actions.close(prompt_bufnr)
      end)

      -- Copy package name on Ctrl-y
      map('i', '<C-y>', function()
        local selection = action_state.get_selected_entry()
        vim.fn.setreg('+', selection.name)
        vim.notify('Copied: ' .. selection.name, vim.log.levels.INFO)
        actions.close(prompt_bufnr)
      end)

      return true
    end,
  })

  picker:find()
end

local fzf = require 'fzf-lua'

local function read_json_file(filepath)
  local file = io.open(filepath, 'r')
  if not file then
    return nil
  end
  local content = file:read('*all')
  file:close()
  local ok, parsed = pcall(vim.json.decode, content)
  if not ok then
    return nil
  end
  return parsed
end

local node_modules_path = vim.uv.cwd() .. '/node_modules/'

local function is_valid_url(url)
  if not url then return false end
  return url:match('^https?://[%w%.%-]+') ~= nil
end

local function get_repo_url(pkg_name)
  local pkg_json_path = node_modules_path .. pkg_name .. '/package.json'
  local pkg_data = read_json_file(pkg_json_path)
  local npm_url = string.format('https://www.npmjs.com/package/%s', pkg_name)
  if not pkg_data then return npm_url end
  if pkg_data.homepage and is_valid_url(pkg_data.homepage) then
    return pkg_data.homepage
  end
  if pkg_data.repository then
    local repo_url = type(pkg_data.repository) == 'string' and pkg_data.repository or pkg_data.repository.url
    if repo_url then
      if repo_url:match('^[%w%-%.]+/[%w%-%.]+$') then
        repo_url = 'https://github.com/' .. repo_url
      else
        repo_url = repo_url:gsub('git%+', ''):gsub('git://', 'https://'):gsub('%.git$', '')
      end
      if is_valid_url(repo_url) then
        return repo_url
      end
    end
  end
  return npm_url
end

local function get_dependencies(package_json)
  local deps, devDeps, peerDeps = {}, {}, {}
  if package_json.dependencies then
    for name, version in pairs(package_json.dependencies) do
      table.insert(deps, { name = name, version = version, type = 'dep', repo_url = get_repo_url(name) })
    end
  end
  if package_json.devDependencies then
    for name, version in pairs(package_json.devDependencies) do
      table.insert(devDeps, { name = name, version = version, type = 'devDep', repo_url = get_repo_url(name) })
    end
  end
  if package_json.peerDependencies then
    for name, version in pairs(package_json.peerDependencies) do
      table.insert(peerDeps, { name = name, version = version, type = 'peerDep', repo_url = get_repo_url(name) })
    end
  end
  table.sort(deps, function(a, b) return a.name > b.name end)
  table.sort(devDeps, function(a, b) return a.name > b.name end)
  table.sort(peerDeps, function(a, b) return a.name > b.name end)
  for _, d in ipairs(devDeps) do table.insert(peerDeps, d) end
  for _, d in ipairs(deps) do table.insert(peerDeps, d) end
  return peerDeps
end

local function open_url(url)
  vim.fn.system('open ' .. url)
end

local function jump_to_package_in_package_json(name)
  vim.cmd 'edit package.json'
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local found
  for i, line in ipairs(lines) do
    if line:match('"' .. name:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]', '%%%1') .. '"') then
      vim.schedule(function()
        vim.api.nvim_win_set_cursor(0, { i, 0 })
        vim.cmd 'normal! zz'
      end)
      found = true
      break
    end
  end
  if not found then
    vim.notify('Package ' .. name .. ' not found in package.json', vim.log.levels.WARN)
  end
end

return function()
  local package_json = read_json_file 'package.json'
  if not package_json then
    vim.notify('No package.json found', vim.log.levels.ERROR)
    return
  end

  local deps = get_dependencies(package_json)
  local lines, map = {}, {}
  for _, dep in ipairs(deps) do
    local line = string.format('%-50s %-20s %-10s', dep.name, dep.version, dep.type)
    lines[#lines + 1] = line
    map[line] = dep
  end

  fzf.fzf_exec(lines, {
    prompt = 'Packages> ',
    actions = {
      ['default'] = function(selected)
        local dep = map[selected[1]]
        if dep then jump_to_package_in_package_json(dep.name) end
      end,
      ['ctrl-o'] = function(selected)
        local dep = map[selected[1]]
        if dep then
          open_url(dep.repo_url)
          vim.notify('Opened: ' .. dep.repo_url, vim.log.levels.INFO)
        end
      end,
      ['ctrl-y'] = function(selected)
        local dep = map[selected[1]]
        if dep then
          vim.fn.setreg('+', dep.name)
          vim.notify('Copied: ' .. dep.name, vim.log.levels.INFO)
        end
      end,
    },
  })
end

local M = {}

local function detect_project_root(_)
  return vim.fn.getcwd()
end

function M.relative_to_root(full_path)
  if not full_path or full_path == '' then
    return full_path or ''
  end

  local root = detect_project_root(full_path)

  if root:sub(-1) ~= '/' then
    root = root .. '/'
  end

  local is_prefix = vim.startswith(full_path, root)

  if not is_prefix then
    return full_path
  end

  return full_path:sub(#root + 1)
end

function M.copy_relative_path(full_path, opts)
  opts = opts or {}

  local rel = M.relative_to_root(full_path)

  vim.fn.setreg('+', rel)
  vim.fn.setreg('"', rel)

  vim.notify('Copied: ' .. rel)
end

return M

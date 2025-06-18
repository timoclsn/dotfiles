local path_utils = require 'utils.path_utils'

local M = {}

function M.copy_path(selected)
  local path = type(selected) == 'table' and selected[1] or selected
  if not path then
    print '[fzf-copy-path] Unable to determine file path for the selection.'
    return
  end
  path_utils.copy_relative_path(path)
end

return M

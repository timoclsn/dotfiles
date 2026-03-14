local action_state = require 'telescope.actions.state'
local path_utils = require 'utils.path_utils'

-- Attempt to fetch a usable path string from a Telescope entry.
-- Different pickers expose the selected path under different keys, so we
-- inspect a handful of common properties and fall back to a best-effort
-- heuristic.
local function extract_path(entry)
  if not entry then
    return nil
  end

  -- Common fields for file-based pickers.
  if entry.path and type(entry.path) == 'string' then
    return entry.path
  end

  if entry.filename and type(entry.filename) == 'string' then
    return entry.filename
  end

  -- Some pickers keep the raw value under `value`.
  if entry.value and type(entry.value) == 'string' and entry.value:match '/' then
    return entry.value
  end

  -- Fallback: the first positional value of the table.
  if type(entry[1]) == 'string' then
    return entry[1]
  end

  return nil
end

local M = {}

function M.copy_path()
  local entry = action_state.get_selected_entry()
  local full_path = extract_path(entry)

  if not full_path then
    print '[telescope-copy-path] Unable to determine file path for the current entry.'
    return
  end

  path_utils.copy_relative_path(full_path)
end

return M

local M = {}

local action_state = require 'telescope.actions.state'
local actions = require 'telescope.actions'

local function open_file_with_position(selection, cmd)
  local filename = selection.filename or selection.value
  if selection.lnum then -- If we have line number info (from live grep)
    -- Open file and move to the correct position
    vim.cmd(cmd .. ' ' .. filename)
    vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col or 0 })
  else
    -- Just open the file
    vim.cmd(cmd .. ' ' .. filename)
  end
end

M.smart_open = function(prompt_bufnr)
  local picker = action_state.get_current_picker(prompt_bufnr)
  local multi_selections = picker:get_multi_selection()

  if #multi_selections > 1 then
    -- Multiple files selected, open the highlighted one and add others to buffer list
    actions.close(prompt_bufnr)
    local current_selection = action_state.get_selected_entry()
    for _, selection in ipairs(multi_selections) do
      if selection == current_selection then
        open_file_with_position(selection, 'edit')
      else
        vim.cmd('badd ' .. (selection.filename or selection.value))
      end
    end
  else
    -- Single file selected (or no selection), use default behavior
    actions.select_default(prompt_bufnr)
  end
end

M.smart_open_split = function(prompt_bufnr)
  local picker = action_state.get_current_picker(prompt_bufnr)
  local multi_selections = picker:get_multi_selection()

  if #multi_selections > 1 then
    -- Multiple files selected, open the highlighted one on the left and others in vertical splits to the right
    actions.close(prompt_bufnr)
    local current_selection = action_state.get_selected_entry()
    open_file_with_position(current_selection, 'edit')
    for _, selection in ipairs(multi_selections) do
      if selection ~= current_selection then
        open_file_with_position(selection, 'vsplit')
      end
    end
  else
    -- Single file selected (or no selection), open in a vertical split
    actions.close(prompt_bufnr)
    local current_selection = action_state.get_selected_entry()
    open_file_with_position(current_selection, 'vsplit')
  end
end

return M

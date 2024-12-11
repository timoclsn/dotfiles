local M = {}

local action_state = require 'telescope.actions.state'
local actions = require 'telescope.actions'

M.smart_open = function(prompt_bufnr)
  local picker = action_state.get_current_picker(prompt_bufnr)
  local multi_selections = picker:get_multi_selection()

  if #multi_selections > 1 then
    -- Multiple files selected, open the highlighted one and add others to buffer list
    actions.close(prompt_bufnr)
    local current_selection = action_state.get_selected_entry()
    for _, selection in ipairs(multi_selections) do
      if selection == current_selection then
        vim.cmd('edit ' .. selection.value)
      else
        vim.cmd('badd ' .. selection.value)
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
    vim.cmd('edit ' .. current_selection.value)
    for _, selection in ipairs(multi_selections) do
      if selection ~= current_selection then
        vim.cmd('vsplit ' .. selection.value)
      end
    end
  else
    -- Single file selected (or no selection), open in a vertical split
    actions.close(prompt_bufnr)
    local current_selection = action_state.get_selected_entry()
    vim.cmd('vsplit ' .. current_selection.value)
  end
end

return M

local M = {}

local function open_with_position(item, cmd)
  local path = type(item) == 'table' and (item.filename or item.value or item[1]) or item
  if not path then return end
  if type(item) == 'table' and item.lnum then
    vim.cmd(cmd .. ' ' .. path)
    vim.api.nvim_win_set_cursor(0, { item.lnum, item.col or 0 })
  else
    vim.cmd(cmd .. ' ' .. path)
  end
end

function M.smart_open(selected)
  selected = selected or {}
  if #selected > 1 then
    open_with_position(selected[1], 'edit')
    for i = 2, #selected do
      vim.cmd('badd ' .. (type(selected[i]) == 'table' and selected[i][1] or selected[i]))
    end
  else
    open_with_position(selected[1], 'edit')
  end
end

function M.smart_open_split(selected)
  selected = selected or {}
  if #selected > 1 then
    open_with_position(selected[1], 'edit')
    for i = 2, #selected do
      open_with_position(selected[i], 'vsplit')
    end
  else
    open_with_position(selected[1], 'vsplit')
  end
end

return M

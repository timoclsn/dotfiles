-- Cache frequently used functions
local nvim_create_autocmd = vim.api.nvim_create_autocmd
local nvim_buf_call = vim.api.nvim_buf_call
local nvim_set_hl = vim.api.nvim_set_hl
local format_path = require('utils.path_formatter').format_path
local match_add = vim.fn.matchadd

-- Pre-compile the format string
local PATH_FORMAT = '%s\t\t%s'

-- Define the display function directly
local function custom_path_display(_, path)
  local formatted = format_path(path)
  local rel_path = formatted.relative_path

  -- Use direct comparison instead of multiple conditions
  if rel_path == '.' or rel_path == '' then
    return formatted.filename
  end

  -- Use pre-compiled format string
  return PATH_FORMAT:format(formatted.filename, rel_path)
end

-- Single autocmd setup with optimized callback
nvim_create_autocmd('FileType', {
  pattern = 'TelescopeResults',
  callback = function(ctx)
    nvim_buf_call(ctx.buf, function()
      match_add('TelescopeParent', '\t\t.*$')
      nvim_set_hl(0, 'TelescopeParent', { link = 'Comment' })
    end)
  end,
})

-- Return the function directly
return custom_path_display

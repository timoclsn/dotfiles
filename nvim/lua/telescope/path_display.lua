local format_path = require 'utils.path_formatter'

-- Pre-compile the format string
local PATH_FORMAT = '%s\t\t%s'

-- Define the display function directly
local function custom_path_display(_, path)
  local formatted_path = format_path(path)
  local relative_path = formatted_path.relative_path

  -- Use direct comparison instead of multiple conditions
  if relative_path == '.' or relative_path == '' then
    return formatted_path.filename
  end

  -- Use pre-compiled format string
  return PATH_FORMAT:format(formatted_path.filename, relative_path)
end

-- Single autocmd setup with optimized callback
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'TelescopeResults',
  callback = function(ctx)
    vim.api.nvim_buf_call(ctx.buf, function()
      vim.fn.matchadd('TelescopeParent', '\t\t.*$')
      vim.api.nvim_set_hl(0, 'TelescopeParent', { link = 'Comment' })
    end)
  end,
})

return custom_path_display

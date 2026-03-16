local format_path = require 'utils.path_formatter'

local PATH_FORMAT = '%s\t\t%s'

local function custom_path_display(_, path)
  local formatted_path = format_path(path)
  local relative_path = formatted_path.relative_path

  if relative_path == '.' or relative_path == '' then
    return PATH_FORMAT:format(formatted_path.filename, '')
  end

  return PATH_FORMAT:format(formatted_path.filename, relative_path)
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'TelescopeResults',
  callback = function(ctx)
    vim.api.nvim_buf_call(ctx.buf, function()
      vim.fn.matchadd('TelescopeResultsComment', '\t\t.*$')
    end)
  end,
})

return custom_path_display

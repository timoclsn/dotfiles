local path_formatter = require 'utils.path_formatter'

local custom_path_display = function(_, path)
  local formatted = path_formatter.format_path(path)

  if formatted.relative_path == '.' or formatted.relative_path == '' then
    return formatted.filename
  end
  return string.format('%s\t\t%s', formatted.filename, formatted.relative_path)
end

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

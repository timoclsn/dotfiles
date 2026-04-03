local restart_nvim = function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].filetype == 'neo-tree' then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  local has_session = vim.v.this_session ~= ''
  local session = has_session and vim.v.this_session or vim.fs.joinpath(vim.fn.stdpath 'state', 'restart-session.vim')

  vim.fn.mkdir(vim.fs.dirname(session), 'p')
  vim.cmd('mksession! ' .. vim.fn.fnameescape(session))

  if not has_session then
    local session_x = session:gsub('%.vim$', 'x.vim')
    vim.fn.writefile({ 'let v:this_session = ""' }, session_x)
  end

  vim.cmd('restart source ' .. vim.fn.fnameescape(session))
end

vim.api.nvim_create_user_command('R', restart_nvim, { desc = 'Restart Neovim and restore the current session' })
vim.api.nvim_create_user_command('Restart', restart_nvim, { desc = 'Restart Neovim and restore the current session' })

vim.api.nvim_create_user_command('Update', function() vim.pack.update() end, { desc = 'Update plugins' })
vim.api.nvim_create_user_command('U', function() vim.pack.update() end, { desc = 'Update plugins' })

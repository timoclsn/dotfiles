-- Counterpart to the ctrl+h/j/k/l binding in rex/init.lua: move between Neovim
-- splits, and hand over to Rex when there is no split left in that direction.
if not vim.env.REX_SESSION or vim.env.REX_SESSION == '' or vim.env.TMUX then
  return
end

local directions = {
  ['<C-h>'] = { wincmd = 'h', direction = 'left' },
  ['<C-j>'] = { wincmd = 'j', direction = 'down' },
  ['<C-k>'] = { wincmd = 'k', direction = 'up' },
  ['<C-l>'] = { wincmd = 'l', direction = 'right' },
}

local navigate = function(wincmd, direction)
  local window = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(wincmd)
  if vim.api.nvim_get_current_win() ~= window then
    return
  end
  vim.system({ 'rex', 'focus', direction, '-s', vim.env.REX_SESSION })
end

-- Mapped on VimEnter so these win over vim-tmux-navigator's own mappings.
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    for lhs, target in pairs(directions) do
      vim.keymap.set({ 'n', 'x' }, lhs, function()
        navigate(target.wincmd, target.direction)
      end, { silent = true, desc = 'Navigate ' .. target.direction .. ' (Neovim/Rex)' })
    end
  end,
})

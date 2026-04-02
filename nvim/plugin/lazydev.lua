vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  once = true,
  callback = function()
    require('lazydev').setup {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    }
  end,
})

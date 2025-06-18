vim.cmd [[
  -- aunmenu PopUp
  anoremenu PopUp.Inspect     <cmd>Inspect<CR>
  amenu PopUp.-1-             <NOP>
  anoremenu PopUp.LspDefinition  <cmd>lua vim.lsp.buf.definition()<CR>
  anoremenu PopUp.LspReferences  <cmd>lua require('fzf-lua').lsp_references()<CR>
  nnoremenu PopUp.Back        <C-t>
  amenu PopUp.-2-             <NOP>
  amenu     PopUp.Hyperlink     gX
]]

local group = vim.api.nvim_create_augroup('nvim_popupmenu', { clear = true })

-- vim.api.nvim_create_autocmd('MenuPopup', {
--   pattern = '*',
--   group = group,
--   desc = 'Custom PopUp Setup',
--   callback = function()
--     -- vim.cmd [[
--     --   amenu disable PopUp.LspDefinition
--     --   amenu disable PopUp.LspReferences
--     --   amenu disable PopUp.Hyperlink
--     -- ]]
--
--     if vim.lsp.get_clients({ bufnr = 0 })[1] then
--       -- vim.cmd [[
--       --   amenu enable PopUp.LspDefinition
--       --   amenu enable PopUp.LspReferences
--       -- ]]
--     end
--
--     local url = vim.fn.expand '<cfile>'
--
--     if url and vim.startswith(url, 'http') then
--       -- vim.cmd [[amenu enable PopUp.Hyperlink]]
--     end
--   end,
-- })

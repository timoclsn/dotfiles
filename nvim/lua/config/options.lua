-- ============================================================================
-- Leader Keys
-- ============================================================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ============================================================================
-- UI & Display
-- ============================================================================
vim.g.have_nerd_font = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.showmode = false
vim.o.termguicolors = true
vim.o.signcolumn = 'yes'
vim.o.cursorline = true
vim.o.colorcolumn = '120'
vim.o.laststatus = 3
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- ============================================================================
-- Editing & Indentation
-- ============================================================================
vim.o.mouse = 'a'
vim.o.breakindent = true
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.updatetime = 250
vim.o.inccommand = 'nosplit'

-- ============================================================================
-- Clipboard
-- ============================================================================
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- ============================================================================
-- Search & Navigation
-- ============================================================================
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.scrolloff = 8

-- ============================================================================
-- Window & Buffer Management
-- ============================================================================
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.switchbuf = 'useopen,usetab'
vim.g.netrw_banner = 0

-- ============================================================================
-- File & Backup Management
-- ============================================================================
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.undofile = true

-- ============================================================================
-- Diagnostics
-- ============================================================================
vim.diagnostic.config {
  severity_sort = true,
  update_in_insert = false,
  underline = { severity = vim.diagnostic.severity.ERROR },
  virtual_text = {
    source = false,
  },
  virtual_lines = false,
  float = {
    source = true,
  },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
}

-- ============================================================================
-- Diff Options
-- ============================================================================
vim.opt.diffopt = {
  'vertical',
  'internal',
  'filler',
  'closeoff',
  'context:12',
  'algorithm:histogram',
  'linematch:60',
  'indent-heuristic',
}

-- ============================================================================
-- Folding
-- ============================================================================
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.foldtext = ''
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()' -- Default to treesitter folding

-- ============================================================================
-- Autocmds
-- ============================================================================

-- LSP Folding
local lsp_folding_group = vim.api.nvim_create_augroup('lsp-folding', { clear = true })

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'Set foldexpr for LSP clients that support foldingRange',
  group = lsp_folding_group,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method 'textDocument/foldingRange' then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end
  end,
})

vim.api.nvim_create_autocmd('LspDetach', {
  group = lsp_folding_group,
  command = 'setl foldexpr<',
})

-- Yank History
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Create yank history',
  group = vim.api.nvim_create_augroup('yank-history', { clear = true }),
  callback = function()
    if vim.v.event.operator == 'y' then
      for i = 9, 1, -1 do
        vim.fn.setreg(tostring(i), vim.fn.getreg(tostring(i - 1)))
      end
    end
  end,
})

-- Highlight Yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

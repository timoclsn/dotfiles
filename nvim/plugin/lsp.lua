-- LSP servers
local servers = {
  astro = {},
  bashls = {},
  copilot = {},
  clangd = {},
  cssls = {},
  emmet_language_server = {},
  eslint = {},
  gh_actions_ls = {},
  gopls = {},
  html = {},
  jsonls = {},
  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
        hint = {
          enable = true,
        },
      },
    },
  },
  prismals = {},
  pyright = {},
  rust_analyzer = {},
  somesass_ls = {},
  svelte = {},
  tailwindcss = {
    settings = {
      tailwindCSS = {
        classFunctions = { 'cva', 'cx' },
      },
    },
  },
  tsgo = {},
  ts_ls = {},
  yamlls = {},
}

for server, settings in pairs(servers) do
  vim.lsp.config(server, settings)
end

-- Mason setup
require('mason').setup()

require('mason-lspconfig').setup {
  ensure_installed = vim.tbl_keys(servers or {}),
  automatic_enable = {
    exclude = { 'ts_ls' },
  },
}

local tools = {
  -- Linters
  'markdownlint',
  'jsonlint',
  'golangci-lint',
  'oxlint',

  -- Formatters
  'black',
  'oxfmt',
  'prettierd',
  'stylua',
}

require('mason-tool-installer').setup {
  ensure_installed = tools,
}

vim.lsp.document_color.enable(true, nil, { style = 'virtual' })

vim.lsp.inline_completion.enable()
vim.keymap.set('i', '<Tab>', function()
  if not vim.lsp.inline_completion.get() then
    return '<Tab>'
  end
end, { expr = true, desc = 'Accept the current inline completion' })

-- LSP keymaps
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('config-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('gd', function()
      require('telescope.builtin').lsp_definitions { reuse_win = true }
    end, 'Goto definition')
    map('grr', function()
      require('telescope.builtin').lsp_references { reuse_win = true }
    end, 'Goto references')
    map('gri', function()
      require('telescope.builtin').lsp_implementations { reuse_win = true }
    end, 'Goto implementation')
    map('grt', function()
      require('telescope.builtin').lsp_type_definitions { reuse_win = true }
    end, 'Goto type Definition')
    map('gO', require('telescope.builtin').lsp_document_symbols, 'Document symbols')
    map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace symbols')
    map('grn', vim.lsp.buf.rename, 'rename symbol')
    map('gra', vim.lsp.buf.code_action, 'Code action', { 'n', 'x' })
    map('grd', vim.lsp.buf.declaration, 'Goto declaration')
    map('<leader>wi', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
    end, '[w]orkspace [i]nlay hints')
    map('<leader>tr', '<cmd>LspRestart tsgo<CR>', '[t]ypescript language server [r]estart')
  end,
})

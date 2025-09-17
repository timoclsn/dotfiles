return {
  {
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      { 'neovim/nvim-lspconfig' },
      { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      local servers = {
        astro = {},
        bashls = {},
        clangd = {},
        cssls = {},
        emmet_language_server = {},
        eslint = {},
        gh_actions_ls = {},
        gitlab_ci_ls = {},
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
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = 'all', -- 'none' | 'literals' | 'all'
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayVariableTypeHints = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = 'all', -- 'none' | 'literals' | 'all'
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayVariableTypeHints = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        yamlls = {},
      }

      -- Configure LSP servers
      for server, settings in pairs(servers) do
        vim.lsp.config(server, settings)
      end

      -- Install and enable LSP servers
      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers or {}),
        automatic_enable = true,
      }

      local tools = {
        -- Linters
        'markdownlint',
        'jsonlint',
        'golangci-lint',

        -- Formatters
        'black',
        'prettierd',
        'stylua',
      }

      -- Install tools
      require('mason-tool-installer').setup {
        ensure_installed = tools,
      }

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
          map('<leader>tr', '<cmd>LspRestart ts_ls<CR>', '[t]ypescript language server [r]estart')
        end,
      })

      vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
        pattern = '*.gitlab-ci*.{yml,yaml}',
        callback = function()
          vim.bo.filetype = 'yaml.gitlab'
        end,
      })
    end,
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
}

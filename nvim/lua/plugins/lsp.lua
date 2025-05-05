return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} },
      { 'williamboman/mason-lspconfig.nvim' },
      { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          map('gd', function()
            require('telescope.builtin').lsp_definitions { reuse_win = true }
          end, '[g]oto [d]efinition')
          map('gR', function()
            require('telescope.builtin').lsp_references { reuse_win = true }
          end, '[g]oto [R]eferences')
          map('gI', function()
            require('telescope.builtin').lsp_implementations { reuse_win = true }
          end, '[g]oto [I]mplementation')
          map('gD', function()
            require('telescope.builtin').lsp_type_definitions { reuse_win = true }
          end, '[g]oto type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[d]ocument [s]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[w]orkspace [s]ymbols')
          map('<leader>r', vim.lsp.buf.rename, '[r]ename symbol')
          map('<leader>c', vim.lsp.buf.code_action, '[c]ode action', { 'n', 'x' })
          map('<leader>D', vim.lsp.buf.declaration, 'Goto [D]eclaration')
          map('<leader>ti', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[t]oggle [i]nlay hints')
        end,
      })

      vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
        pattern = '*.gitlab-ci*.{yml,yaml}',
        callback = function()
          vim.bo.filetype = 'yaml.gitlab'
        end,
      })

      local servers = {
        -- LSP servers
        astro = {},
        bashls = {},
        cssls = {},
        emmet_language_server = {},
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
        rust_analyzer = {},
        somesass_ls = {},
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

        -- Linters
        eslint = {},
        markdownlint = {},
        jsonlint = {},

        -- Formatters
        prettierd = {},
        stylua = {},
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }
      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local config = servers[server_name] or {}
            vim.lsp.config(server_name, config)
            vim.lsp.enable(server_name)
          end,
        },
      }
    end,
  },
}

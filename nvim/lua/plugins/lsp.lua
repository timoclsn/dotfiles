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
          on_attach = function(client, bufnr)
            require('twoslash-queries').attach(client, bufnr)
          end,
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
          map('gd', require('fzf-lua').lsp_definitions, '[g]oto [d]efinition')
          map('gR', require('fzf-lua').lsp_references, '[g]oto [R]eferences')
          map('gI', require('fzf-lua').lsp_implementations, '[g]oto [I]mplementation')
          map('gD', require('fzf-lua').lsp_typedefs, '[g]oto type [D]efinition')
          map('<leader>ds', require('fzf-lua').lsp_document_symbols, '[d]ocument [s]ymbols')
          map('<leader>ws', require('fzf-lua').lsp_workspace_symbols, '[w]orkspace [s]ymbols')
          map('<leader>r', vim.lsp.buf.rename, '[r]ename symbol')
          map('<leader>c', vim.lsp.buf.code_action, '[c]ode action', { 'n', 'x' })
          map('<leader>D', vim.lsp.buf.declaration, 'Goto [D]eclaration')
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

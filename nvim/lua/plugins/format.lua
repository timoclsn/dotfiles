return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[f]ormat buffer',
      },
    },
    opts = function()
      local formatters = {
        go = { 'gofmt' },
        lua = { 'stylua' },
        python = { 'black' },
        rust = { 'rustfmt' },
      }

      local web_filetypes = {
        'astro',
        'css',
        'graphql',
        'html',
        'javascript',
        'javascriptreact',
        'json',
        'less',
        'markdown',
        'markdown.mdx',
        'mdx',
        'prisma',
        'scss',
        'svelte',
        'typescript',
        'typescriptreact',
        'vue',
        'yaml',
      }

      for _, ft in ipairs(web_filetypes) do
        formatters[ft] = { 'prettierd', 'prettier', stop_after_first = true }
      end

      return {
        notify_on_error = false,
        format_on_save = function(bufnr)
          local disable_filetypes = { c = true, cpp = true }
          if disable_filetypes[vim.bo[bufnr].filetype] then
            return nil
          else
            return {
              timeout_ms = 500,
              lsp_format = 'fallback',
            }
          end
        end,
        formatters_by_ft = formatters,
      }
    end,
  },
}

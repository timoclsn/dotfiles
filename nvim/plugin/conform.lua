local formatters = {
  go = { 'gofmt' },
  lua = { 'stylua' },
  python = { 'black' },
  rust = { 'rustfmt' },
  zig = { 'zigfmt' },
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

-- Filetypes oxfmt supports (subset of web_filetypes; no astro/svelte/prisma/mdx).
-- oxfmt is preferred where the project has it installed locally, otherwise we
-- fall back to prettier. oxfmt is not installed globally, so it only wins in
-- projects that actually use it.
local oxfmt_filetypes = {
  'css',
  'graphql',
  'html',
  'javascript',
  'javascriptreact',
  'json',
  'less',
  'markdown',
  'scss',
  'typescript',
  'typescriptreact',
  'vue',
  'yaml',
}

for _, ft in ipairs(oxfmt_filetypes) do
  formatters[ft] = { 'oxfmt', 'prettierd', 'prettier', stop_after_first = true }
end

require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local disable_filetypes = {
      c = true,
      cpp = true,
    }

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

vim.keymap.set('', 'gq', function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end, { desc = 'Format buffer' })

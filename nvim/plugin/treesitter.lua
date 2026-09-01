local ts = require 'nvim-treesitter'

ts.install {
  'astro',
  'bash',
  'c',
  'css',
  'diff',
  'gitcommit',
  'git_config',
  'gitignore',
  'go',
  'html',
  'javascript',
  'json',
  'lua',
  'luadoc',
  'make',
  'markdown',
  'markdown_inline',
  'python',
  'query',
  'rust',
  'svelte',
  'toml',
  'tsx',
  'typescript',
  'xml',
  'yaml',
}

local group = vim.api.nvim_create_augroup('TreesitterSetup', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  desc = 'Enable treesitter highlighting and indentation',
  callback = function(event)
    local lang = vim.treesitter.language.get_lang(event.match) or event.match
    local buf = event.buf

    if not pcall(vim.treesitter.start, buf, lang) then
      return
    end

    -- Without an indents query the treesitter indentexpr returns 0 for every
    -- line, which would override Neovim's own indent plugin (breaking e.g. the
    -- mandatory tabs in Makefile recipes).
    if vim.treesitter.query.get(lang, 'indents') then
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- Treesitter context
require('treesitter-context').setup {
  max_lines = 1,
  multiline_threshold = 1,
  trim_scope = 'inner',
  mode = 'cursor',
  min_window_height = 0,
}

vim.keymap.set('n', 'gC', function()
  require('treesitter-context').go_to_context(vim.v.count1)
end, { silent = true, desc = '[g]o to [C]ontext' })

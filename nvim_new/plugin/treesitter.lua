-- PackChanged hook for TSUpdate on install/update
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'nvim-treesitter' then
      if ev.data.kind == 'install' or ev.data.kind == 'update' then
        if not ev.data.active then
          vim.cmd.packadd 'nvim-treesitter'
        end
        vim.cmd 'TSUpdate'
      end
    end
  end,
})

vim.pack.add {
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },
  'https://github.com/nvim-treesitter/nvim-treesitter-context',
}

-- Treesitter setup
local ts = require 'nvim-treesitter'

-- Install core parsers at startup
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
  'tmux',
  'toml',
  'tsx',
  'typescript',
  'xml',
  'yaml',
}

local group = vim.api.nvim_create_augroup('TreesitterSetup', { clear = true })

-- Auto-install parsers and enable highlighting on FileType
vim.api.nvim_create_autocmd('FileType', {
  group = group,
  desc = 'Enable treesitter highlighting and indentation',
  callback = function(event)
    local lang = vim.treesitter.language.get_lang(event.match) or event.match
    local buf = event.buf

    -- Start highlighting immediately (works if parser exists)
    pcall(vim.treesitter.start, buf, lang)

    -- Enable treesitter indentation
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
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

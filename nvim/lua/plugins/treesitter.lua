return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    branch = 'main',
    build = ':TSUpdate',
    config = function()
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
        'toml',
        'tsx',
        'typescript',
        'xml',
        'yaml',
      }

      local group = vim.api.nvim_create_augroup('TreesitterSetup', { clear = true })

      local ignore_filetypes = {
        'checkhealth',
        'lazy',
        'mason',
        'ministarter',
      }

      -- Auto-install parsers and enable highlighting on FileType
      vim.api.nvim_create_autocmd('FileType', {
        group = group,
        desc = 'Enable treesitter highlighting and indentation',
        callback = function(event)
          if vim.tbl_contains(ignore_filetypes, event.match) then
            return
          end

          local lang = vim.treesitter.language.get_lang(event.match) or event.match
          local buf = event.buf

          -- Start highlighting immediately (works if parser exists)
          pcall(vim.treesitter.start, buf, lang)

          -- Enable treesitter indentation
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

          -- Install missing parsers (async, no-op if already installed)
          ts.install { lang }
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('treesitter-context').setup {
        max_lines = 1, -- How many lines the window should span. Values <= 0 mean no limit.
        multiline_threshold = 1, -- Maximum number of lines to show for a single context
        trim_scope = 'inner', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
        min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
      }

      vim.keymap.set('n', 'gC', function()
        require('treesitter-context').go_to_context(vim.v.count1)
      end, { silent = true, desc = '[g]o to [C]ontext' })
    end,
  },
}

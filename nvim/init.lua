vim.loader.enable()

require 'config.options'
require 'config.keymaps'

-- PackChanged hooks
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind

    if kind ~= 'install' and kind ~= 'update' then
      return
    end

    if name == 'nvim-treesitter' then
      if not ev.data.active then
        vim.cmd.packadd 'nvim-treesitter'
      end
      vim.cmd 'TSUpdate'
    elseif name == 'fff.nvim' then
      require('fff.download').download_or_build_binary()
    end
  end,
})

-- Plugins
vim.pack.add {
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.*' },
  'https://github.com/nat-418/boole.nvim',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/sindrets/diffview.nvim',
  'https://github.com/jinh0/eyeliner.nvim',
  'https://github.com/dmtrKovalenko/fff.nvim',
  'https://github.com/j-hui/fidget.nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/folke/lazydev.nvim',
  'https://github.com/onsails/lspkind.nvim', -- dependency of blink.cmp
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/nvim-mini/mini.nvim',
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '3.*' },
  'https://github.com/MunifTanjim/nui.nvim', -- dependency of neo-tree
  'https://github.com/mfussenegger/nvim-lint',
  'https://github.com/neovim/nvim-lspconfig',
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  'https://github.com/nvim-treesitter/nvim-treesitter-context',
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },
  'https://github.com/windwp/nvim-ts-autotag',
  'https://github.com/nvim-lua/plenary.nvim', -- dependency of telescope
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  'https://github.com/folke/snacks.nvim',
  'https://github.com/benfowler/telescope-luasnip.nvim',
  'https://github.com/nvim-telescope/telescope-ui-select.nvim',
  'https://github.com/natecraddock/telescope-zf-native.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/axelvc/template-string.nvim',
  'https://github.com/folke/todo-comments.nvim',
  'https://github.com/folke/tokyonight.nvim',
  'https://github.com/folke/ts-comments.nvim',
  'https://github.com/christoomey/vim-tmux-navigator',
  'https://github.com/folke/which-key.nvim',
}

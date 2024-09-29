-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '<C-e>', ':Neotree toggle<CR>', desc = 'Toggle File [E]xplorer', silent = true },
    { '<leader>rf', ':Neotree reveal<CR>', desc = '[R]eveal [F]ile', silent = true },
  },
  opts = {
    close_if_last_window = true,
    filesystem = {
      window = {
        position = 'right',
        width = 60,
        mapping_options = {
          nowait = true,
        },
        mappings = {
          ['<space>'] = 'toggle_node',
          ['<C-e>'] = 'close_window',
          ['h'] = 'focus_preview',
        },
      },
      filtered_items = {
        show_hidden_count = false,
        hide_dotfiles = false,
        never_show = {
          '.git',
          '.DS_Store',
        },
      },
    },
  },
}

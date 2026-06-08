vim.pack.add {
  'https://github.com/nvim-neo-tree/neo-tree.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/dmtrKovalenko/fff.nvim',
}

-- ============================================================================
-- Neo-tree
-- ============================================================================

local neo_tree_opts = {
  close_if_last_window = true,
  filesystem = {
    window = {
      position = 'right',
      width = 60,
      mapping_options = {
        nowait = true,
      },
      mappings = {
        ['z'] = 'none',
        ['zR'] = 'close_all_nodes',
        ['C'] = 'close_all_subnodes',
        ['zM'] = 'expand_all_nodes',
        ['l'] = 'open',
        ['<C-v>'] = 'open_vsplit',
        ['h'] = 'close_node',
        ['<space>'] = { 'toggle_preview', config = { use_float = true } },
        ['P'] = 'focus_preview',
        ['<C-e>'] = 'close_window',
        ['<C-r>'] = {
          command = function(state)
            local node = state.tree:get_node()
            vim.fn.system('open -R ' .. vim.fn.shellescape(node.path))
          end,
          desc = 'Reveal in Finder',
        },
        ['<C-y>'] = {
          function(state)
            local node = state.tree:get_node()
            local full_path = node:get_id()

            require('utils.path_utils').copy_relative_path(full_path)
          end,
          desc = 'Copy Path to Clipboard',
        },
      },
    },
    filtered_items = {
      show_hidden_count = false,
      hide_dotfiles = false,
      hide_gitignored = false,
      never_show = {
        '.git',
        '.DS_Store',
      },
    },
  },
}

local function on_move(data)
  require('snacks').rename.on_rename_file(data.source, data.destination)
end
local events = require 'neo-tree.events'
neo_tree_opts.event_handlers = neo_tree_opts.event_handlers or {}
vim.list_extend(neo_tree_opts.event_handlers, {
  { event = events.FILE_MOVED, handler = on_move },
  { event = events.FILE_RENAMED, handler = on_move },
})

require('neo-tree').setup(neo_tree_opts)

vim.keymap.set('n', '<C-e>', ':Neotree toggle<CR>', { desc = 'Toggle File [e]xplorer', silent = true })
vim.keymap.set('n', '<leader>e', ':Neotree reveal<CR>', { desc = 'Reveal file in [e]xplorer', silent = true })

-- ============================================================================
-- fff.nvim
-- ============================================================================

require('fff').setup {
  prompt = '> ',
  title = 'Search Files',
  keymaps = {
    close = '<C-c>',
  },
}

vim.keymap.set('n', '<leader>sf', function()
  require('fff').find_files()
end, { desc = '[s]earch [f]iles' })

vim.keymap.set('n', '<leader>sg', function()
  require('fff').live_grep {
    grep = {
      modes = { 'fuzzy', 'plain', 'regex' },
    },
  }
end, { desc = '[s]earch by [g]rep' })

vim.keymap.set('n', '<leader>sw', function()
  local word = vim.fn.expand '<cword>'
  require('fff').live_grep {
    query = word,
    grep = {
      modes = { 'plain', 'regex', 'fuzzy' },
    },
  }
end, { desc = '[s]earch current [w]ord' })

vim.keymap.set('x', '<leader>sg', function()
  local visual_selection = function()
    local save_previous = vim.fn.getreg 'a'
    vim.cmd 'noau normal! "ay'
    local selection = vim.fn.getreg 'a'
    vim.fn.setreg('a', save_previous)
    return selection:gsub('\n', ' '):gsub('^%s*(.-)%s*$', '%1')
  end

  local selected_text = visual_selection()

  require('fff').live_grep {
    query = selected_text,
    grep = {
      modes = { 'plain', 'regex', 'fuzzy' },
    },
  }
end, { desc = '[s]earch by [g]rep' })

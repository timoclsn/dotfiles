-- nvim/lua/config/keymaps.lua

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Normal mode mappings
map('n', '<C-s>', ':w<CR>', { silent = true })
map('n', '<C-q>', ':q<CR>', { silent = true })
map('n', '<C-w>q', ':qa<CR>', { silent = true })
map('n', 'gg', 'G')
map('n', 'G', 'gg')

-- Insert mode mappings
map('i', 'jk', '<Esc>')
map('i', 'kj', '<Esc>')

-- Visual mode mappings
map('v', 'J', ":m '>+1<CR>gv=gv")
map('v', 'K', ":m '<-2<CR>gv=gv")

-- Leader key mappings
map('n', '<Leader>ff', ':Telescope find_files<CR>')
map('n', '<Leader>fg', ':Telescope live_grep<CR>')
map('n', '<Leader>fb', ':Telescope buffers<CR>')
map('n', '<Leader>fh', ':Telescope help_tags<CR>')
map('n', '<Leader>fr', ':Telescope lsp_references<CR>')
map('n', '<Leader>fo', ':Telescope lsp_document_symbols<CR>')
map('n', '<Leader>fc', ':Telescope lsp_code_actions<CR>')
map('n', '<Leader>fd', ':Telescope diagnostics<CR>')
map('n', '<Leader>fp', ':Telescope projects<CR>')
map('n', '<Leader>fn', ':Telescope notify<CR>')
map('n', '<Leader>fm', ':Telescope marks<CR>')
map('n', '<Leader>fs', ':Telescope lsp_dynamic_workspace_symbols<CR>')
map('n', '<Leader>ft', ':Telescope filetypes<CR>')
map('n', '<Leader>fw', ':Telescope grep_string<CR>')
map('n', '<Leader>fx', ':Telescope extensions<CR>')
map('n', '<Leader>fy', ':Telescope yaml_schema<CR>')
map('n', '<Leader>fz', ':Telescope zoxide<CR>')
map('n', '<Leader>fl', ':Telescope file_browser<CR>')
map('n', '<Leader>fn', ':Telescope notify<CR>')
map('n', '<Leader>fm', ':Telescope marks<CR>')
map('n', '<Leader>fs', ':Telescope lsp_dynamic_workspace_symbols<CR>')
map('n', '<Leader>ft', ':Telescope filetypes<CR>')
map('n', '<Leader>fw', ':Telescope grep_string<CR>')
map('n', '<Leader>fx', ':Telescope extensions<CR>')
map('n', '<Leader>fz', ':Telescope zoxide<CR>')
map('n', '<Leader>fl', ':Telescope file_browser<CR>')

-- Buffer navigation
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- Window resizing
map('n', '<C-Up>', ':resize +2<CR>')
map('n', '<C-Down>', ':resize -2<CR>')
map('n', '<C-Left>', ':vertical resize -2<CR>')
map('n', '<C-Right>', ':vertical resize +2<CR>')

-- Toggle options
map('n', '<Leader>tt', ':set paste!<CR>')
map('n', '<Leader>tw', ':set wrap!<CR>')
map('n', '<Leader>ts', ':set spell!<CR>')
map('n', '<Leader>td', ':set number!<CR>')
map('n', '<Leader>tl', ':set relativenumber!<CR>')
map('n', '<Leader>tg', ':set cursorline!<CR>')
map('n', '<Leader>ti', ':set ignorecase!<CR>')
map('n', '<Leader>tI', ':set smartcase!<CR>')
map('n', '<Leader>to', ':set hlsearch!<CR>')

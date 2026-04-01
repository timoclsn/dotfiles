-- Ghostty syntax highlighting (local, non-git plugin)
vim.opt.rtp:append '/Applications/Ghostty.app/Contents/Resources/vim/vimfiles/'

-- Plugin configurations (each file handles its own vim.pack.add)
require 'plugins.colorscheme'
require 'plugins.snacks'
require 'plugins.treesitter'
require 'plugins.mini'
require 'plugins.lsp'
require 'plugins.completion'
require 'plugins.telescope'
require 'plugins.files'
require 'plugins.git'
require 'plugins.format'
require 'plugins.lint'
require 'plugins.keys'
require 'plugins.typescript'
require 'plugins.utils'

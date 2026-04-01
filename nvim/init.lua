vim.loader.enable()
require 'config.options'
require 'config.keymaps'

-- Ghostty syntax highlighting (local, non-git plugin)
vim.opt.rtp:append '/Applications/Ghostty.app/Contents/Resources/vim/vimfiles/'

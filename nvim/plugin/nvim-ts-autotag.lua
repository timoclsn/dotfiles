-- Closing tags are inserted by this plugin; renaming a tag pair is handled by
-- the language server via vim.lsp.linked_editing_range, which mirrors the edit
-- while typing instead of waiting for InsertLeave. Filetypes whose server does
-- not support linkedEditingRange keep the plugin's own renaming.
require('nvim-ts-autotag').setup {
  per_filetype = {
    html = { enable_rename = false },
    svelte = { enable_rename = false },
    javascriptreact = { enable_rename = false },
    typescriptreact = { enable_rename = false },
  },
}

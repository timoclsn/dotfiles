return {
  {
    'saghen/blink.cmp',
    dependencies = {
      'onsails/lspkind.nvim',
      'nvim-tree/nvim-web-devicons',
      'brenoprata10/nvim-highlight-colors',
      'Kaiser-Yang/blink-cmp-avante',
    },
    version = '1.*',
    opts = {
      keymap = {
        preset = 'none',
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'cancel' },
        ['<CR>'] = { 'select_and_accept', 'fallback' },
        ['<C-y>'] = { 'select_and_accept', 'fallback' },

        ['<C-k>'] = { 'select_prev', 'fallback' },
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },

        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },

        ['<C-l>'] = { 'snippet_forward', 'fallback' },
        ['<C-h>'] = { 'snippet_backward', 'fallback' },
      },
      completion = {
        documentation = {
          auto_show = true,
        },
        menu = {
          draw = {
            components = {
              kind_icon = {
                text = function(ctx)
                  local icon = ctx.kind_icon

                  -- First handle LSP kind icons
                  if not vim.tbl_contains({ 'Path' }, ctx.source_name) then
                    local lspkind = require 'lspkind'
                    icon = lspkind.symbolic(ctx.kind, {
                      mode = 'symbol',
                    })
                  else
                    -- Handle Path source with devicons
                    local dev_icon, _ = require('nvim-web-devicons').get_icon(ctx.label)
                    if dev_icon then
                      icon = dev_icon
                    end
                  end

                  print(icon)

                  -- Then check for color highlighting
                  if ctx.item.source_name == 'LSP' then
                    local color_item = require('nvim-highlight-colors').format(ctx.item.documentation, { kind = ctx.kind })
                    if color_item and color_item.abbr and color_item.abbr ~= '' then
                      icon = color_item.abbr
                    end
                  end

                  return icon .. ctx.icon_gap
                end,
              },
            },
          },
        },
      },
      sources = {
        default = {
          'avante',
          'snippets',
          'lsp',
          'path',
          'buffer',
        },
        providers = {
          snippets = {
            min_keyword_length = 2,
            score_offset = 4,
          },
          avante = {
            module = 'blink-cmp-avante',
            name = 'Avante',
            opts = {},
          },
        },
      },
      signature = { enabled = true },
    },
    opts_extend = { 'sources.default' },
  },
}

return {
  {
    'saghen/blink.cmp',
    dependencies = {
      'onsails/lspkind.nvim',
      'brenoprata10/nvim-highlight-colors',
      'Kaiser-Yang/blink-cmp-avante',
      'folke/lazydev.nvim',
      'fang2hou/blink-copilot',
    },
    version = '1.*',
    opts = {
      keymap = {
        preset = 'none',
        ['<C-space>'] = { 'show', 'hide' },
        ['<C-c>'] = { 'cancel', 'fallback' },
        ['<CR>'] = { 'select_and_accept', 'fallback' },

        ['<C-k>'] = { 'select_prev', 'fallback' },
        ['<C-j>'] = { 'select_next', 'fallback' },

        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },

        ['<C-l>'] = { 'snippet_forward', 'fallback' },
        ['<C-h>'] = { 'snippet_backward', 'fallback' },

        ['<C-b>'] = { 'show_signature', 'hide_signature', 'fallback' },
        ['<C-f>'] = { 'show_documentation', 'hide_documentation', 'fallback' },
      },
      completion = {
        documentation = {
          auto_show = true,
        },
        accept = {
          auto_brackets = {
            enabled = false,
          },
        },
        menu = {
          draw = {
            components = {
              kind_icon = {
                text = function(ctx)
                  local icon = ctx.kind_icon

                  -- First check for color highlighting (takes precedence)
                  if ctx.item.source_name == 'LSP' then
                    local color_item = require('nvim-highlight-colors').format(ctx.item.documentation, { kind = ctx.kind })
                    if color_item and color_item.abbr ~= '' then
                      return color_item.abbr .. ctx.icon_gap
                    end
                  end

                  -- Handle Path source with devicons
                  if ctx.source_name == 'Path' then
                    local dev_icon, _ = require('nvim-web-devicons').get_icon(ctx.label)
                    if dev_icon then
                      return dev_icon .. ctx.icon_gap
                    end
                    return icon .. ctx.icon_gap
                  end

                  -- Handle copilot source (keep original icon)
                  if ctx.source_name == 'copilot' then
                    return icon .. ctx.icon_gap
                  end

                  -- Default to lspkind for other sources
                  local lspkind = require 'lspkind'
                  icon = lspkind.symbolic(ctx.kind, {
                    mode = 'symbol',
                  })

                  return icon .. ctx.icon_gap
                end,
              },
            },
          },
        },
      },
      sources = {
        default = {
          'snippets',
          'lsp',
          'path',
          'buffer',
          'avante',
          'lazydev',
          'copilot',
        },
        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-copilot',
            async = true,
          },
          avante = {
            module = 'blink-cmp-avante',
            name = 'Avante',
            opts = {},
          },
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
        },
      },
      signature = { enabled = true },
    },
    opts_extend = { 'sources.default' },
  },
}

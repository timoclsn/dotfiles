return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      copilot_model = 'gpt-4o-copilot',
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        keymap = {
          accept = '<Tab>',
          next = '<C-j>',
          prev = '<C-k>',
          dismiss = '<C-e>',
        },
      },
    },
  },
  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    lazy = false,
    build = 'make',
    dependencies = {
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- The below dependencies are optional,
      'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
      'zbirenbaum/copilot.lua', -- for providers='copilot'
      {
        -- support for image pasting
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
    opts = {
      provider = 'copilot',
      copilot = {
        -- model = 'claude-3.5-sonnet',
        -- model = 'claude-3.7-sonnet',
        model = 'claude-3.7-sonnet-thought',
        tmperature = 1,
        max_tokens = 20000,
      },
      hints = {
        enabled = false,
      },
      behaviour = {
        use_cwd_as_project_root = true,
        enable_claude_text_editor_tool_mode = true,
      },
      windows = {
        position = 'left',
        ask = {
          start_insert = false,
        },
      },
      system_prompt = function()
        local hub = require('mcphub').get_hub_instance()
        return hub:get_active_servers_prompt()
      end,
      -- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
      custom_tools = function()
        return {
          require('mcphub.extensions.avante').mcp_tool(),
        }
      end,
    },
  },
  {
    'ravitemer/mcphub.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    build = 'npm install -g mcp-hub@latest',
    config = function()
      require('mcphub').setup {
        port = 3300,
        config = vim.fn.expand '~/.mcpservers.json',
      }
    end,
  },
}

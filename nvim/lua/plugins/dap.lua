return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      { 'rcarriga/nvim-dap-ui', dependencies = { 'nvim-neotest/nvim-nio' } },
      -- build debugger from source
      {
        'microsoft/vscode-js-debug',
        version = '1.x',
        build = 'npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out',
      },
    },
    keys = {
      -- Your key mappings are fine
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
      },
      {
        '<leader>dc',
        function()
          require('dap').continue()
        end,
      },
      {
        "<C-'>",
        function()
          require('dap').step_over()
        end,
      },
      {
        '<C-;>',
        function()
          require('dap').step_into()
        end,
      },
      {
        '<C-:>',
        function()
          require('dap').step_out()
        end,
      },
    },
    config = function()
      -- Set up the adapter explicitly
      local dap = require 'dap'

      -- Define JavaScript/TypeScript Debug adapters with fixed ports
      dap.adapters['pwa-node'] = {
        type = 'server',
        host = 'localhost',
        port = 8123,
        executable = {
          command = 'node',
          args = {
            vim.fn.stdpath 'data' .. '/lazy/vscode-js-debug/dist/src/vsDebugServer.js',
            '8123',
          },
        },
      }

      dap.adapters['pwa-chrome'] = {
        type = 'server',
        host = 'localhost',
        port = 8124,
        executable = {
          command = 'node',
          args = {
            vim.fn.stdpath 'data' .. '/lazy/vscode-js-debug/dist/src/vsDebugServer.js',
            '8124',
          },
        },
      }

      for _, language in ipairs { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' } do
        require('dap').configurations[language] = {
          -- Your configurations are fine
          {
            type = 'pwa-node',
            request = 'attach',
            processId = require('dap.utils').pick_process,
            name = 'Attach debugger to existing `node --inspect` process',
            sourceMaps = true,
            cwd = '${workspaceFolder}',
          },
          {
            type = 'pwa-chrome',
            name = 'Launch Chrome to debug client',
            request = 'launch',
            url = 'http://localhost:3000',
            sourceMaps = true,
            protocol = 'inspector',
            webRoot = '${workspaceFolder}',
          },
          language == 'javascript' and {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch file in new node process',
            program = '${file}',
            cwd = '${workspaceFolder}',
          } or nil,
        }
      end

      require('dapui').setup()
      local dapui = require 'dapui'
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open { reset = true }
      end
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close
    end,
  },
}

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",

    },
    keys = {
      { "<leader>db", "<cmd>DapToggleBreakpoint<cr>", desc = "Toggle break point" },
      { "<F5>", "<cmd>DapToggleBreakpoint<cr>", desc = "Toggle break point" },
      { "<leader>dc", "<cmd>DapContinue<cr>",         desc = "Debugger - continue" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local dapvt = require("nvim-dap-virtual-text")

      -- DAP UI setup
      dapui.setup()
      dapvt.setup()

      -- Open and close DAP UI automatically
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Optional: custom keymaps for stepping
      local map = vim.keymap.set
      map("n", "<F8>", function() dap.step_over() end, { desc = "Step over" })
      map("n", "<F7>", function() dap.step_into() end, { desc = "Step into" })
      map("n", "<S-F8>", function() dap.step_out() end, { desc = "Step out" })
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    lazy = false,
    dependencies = { "mfussenegger/nvim-dap" },
    ft = "python", -- load only for Python files
    config = function()
      local dap_python = require("dap-python")

      -- Use uv as the Python interpreter
      dap_python.setup(".venv/bin/python")

      -- Optional: custom test keymaps
      local map = vim.keymap.set
      map("n", "<leader>dn", function() dap_python.test_method() end, { desc = "Debug nearest test" })
      map("n", "<leader>df", function() dap_python.test_class() end, { desc = "Debug test class" })
      map("v", "<leader>ds", function() dap_python.debug_selection() end, { desc = "Debug selection" })
    end,
  },

}

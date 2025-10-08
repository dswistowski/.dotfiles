return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python", -- Python adapter
    },
    lazy = false,
    config = function()
      local neotest = require("neotest")

      neotest.setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
            args = { "--maxfail=1", "--disable-warnings" },
            runner = "pytest",
          }),
        },
      })

      -- Keymaps
      local map = vim.keymap.set
      map("n", "<leader>tt", function() neotest.run.run() end, { desc = "Run nearest test" })
      map("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Run tests in file" })
      map("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "Toggle summary" })
      map("n", "<leader>to", function() neotest.output.open({ enter = true }) end, { desc = "Show test output" })
    end,
  },
}


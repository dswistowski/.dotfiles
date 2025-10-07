return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-neotest/neotest-python",
	},
	config = function()
		local neotest = require("neotest")

		neotest.setup({
			adapters = {
				require("neotest-python")({}),
			},
		})

		vim.keymap.set("n", "<leader>tt", function()
			neotest.run.run()
		end, { desc = "Run nearest test" })
		vim.keymap.set("n", "<leader>tf", function()
			vim.schedule(function()
    require("neotest").run.run(vim.fn.expand("%"))
  end)
		end, { desc = "Run test file" })
		vim.keymap.set("n", "<leader>ts", function()
			neotest.summary.toggle()
		end, { desc = "Toggle summary" })
		vim.keymap.set("n", "<leader>to", function()
			neotest.output.open({ enter = true })
		end, { desc = "Show test output" })
	end,
}

return {
	"vim-test/vim-test",
	lazy = false,
	init = function()
		vim.g["test#strategy"] = "neovim"
	end,
	keys = {
		{ "<leader>tt", "<cmd>TestNearest<cr>", desc = "Test Nearest" },
		{ "<leader>tf", "<cmd>TestFile<cr>", desc = "Test File" },
		{ "<leader>ts", "<cmd>TestSuite<cr>", desc = "Test Suite" },
		{ "<leader>tl", "<cmd>TestLast<cr>", desc = "Test Last" },
		{ "<leader>tv", "<cmd>TestVisit<cr>", desc = "Test Visit" },
	},
}

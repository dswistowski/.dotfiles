require("nvim-treesitter.configs").setup({
	ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "javascript" },
	auto_install = false,
	highlight = { enable = true, additional_vim_regex_highlighting = false },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<C-n>",
			node_incremental = "<C-n>",
			scope_incremental = "<C-s>",
			node_decremental = "<C-m>",
		},
	},
})

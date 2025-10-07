return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate", -- auto-update parsers on install
		event = { "BufReadPost", "BufNewFile" }, -- lazy-load only when editing files
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"nvim-treesitter/nvim-treesitter-context",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"python",
					"javascript",
					"typescript",
					"bash",
					"json",
					"jsonc",
					"yaml",
					"html",
					"css",
					"markdown",
					"markdown_inline",
				},

				highlight = {
					enable = true, -- enable syntax highlighting
					additional_vim_regex_highlighting = false,
				},
				indent = {
					enable = true, -- better indentation
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-n>",
						node_incremental = "<C-n>",
						scope_incremental = "<C-s>",
						node_decremental = "<C-m>",
					},
				},

				textobjects = {
					select = {
						enable = true,
						lookahead = true, -- jump forward to textobject
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
							["aP"] = "@parameter.outer",
							["iP"] = "@parameter.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = true, -- add to jumplist
						goto_next_start = {
							["]f"] = "@function.outer",
							["]c"] = "@class.outer",
						},
						goto_next_end = {
							["]F"] = "@function.outer",
							["]C"] = "@class.outer",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
							["[c"] = "@class.outer",
						},
						goto_previous_end = {
							["[F"] = "@function.outer",
							["[C"] = "@class.outer",
						},
					},
					swap = {
						enable = true,
						swap_next = {
							["<leader>a"] = "@parameter.inner",
						},
						swap_previous = {
							["<leader>A"] = "@parameter.inner",
						},
					},
				},
			})
		end,
	},
}

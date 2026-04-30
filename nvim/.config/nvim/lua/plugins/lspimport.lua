return {
	{
		"stevanmilic/nvim-lspimport",
		lazy = true,
		config = function()
			vim.keymap.set("n", "gri", require("lspimport").import, { noremap = true, desc = "Auto import" })
		end,
	},
}

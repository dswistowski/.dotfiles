return {
    "mason-org/mason-lspconfig.nvim",
    opts = {},
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
	{ "WhoIsSethDaniel/mason-tool-installer.nvim", opts = {
		 ensure_installed = {
                "lua_ls",
                "stylua",
                "pyright",
                "ruff",
        "copilot-language-server",
	}}
}
    },
}

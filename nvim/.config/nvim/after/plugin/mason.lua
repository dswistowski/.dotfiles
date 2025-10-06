require('mason').setup()
require("mason-lspconfig").setup()

require('mason-tool-installer').setup({
	ensure_installed = {
		"lua_ls",
		"stylua",
		"pyright",
		"ruff",
        "copilot-language-server",
	}

})


local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("pyright", {
  capabilities = capabilities,
})


vim.lsp.config('lua_ls', {
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = {
          'vim',
          'require'
        },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = {
        enable = false,
      },
    },
  },
})




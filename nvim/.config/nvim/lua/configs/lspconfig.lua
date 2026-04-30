local config = require("nvchad.configs.lspconfig")
config.defaults()

local servers = { "html", "cssls", "zuban" }
vim.lsp.enable(servers)


-- read :h vim.lsp.config for changing options of lsp servers 

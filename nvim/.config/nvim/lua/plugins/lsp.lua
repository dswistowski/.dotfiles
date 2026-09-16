return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "saghen/blink.cmp",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup {
      -- add more server names here, then `:Mason` to install / check status
      ensure_installed = { "lua_ls", "pyright", "ruff" },
    }

    vim.lsp.config("*", {
      capabilities = require("blink.cmp").get_lsp_capabilities(),
    })

    vim.lsp.enable { "lua_ls", "pyright", "ruff" }
  end,
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master", -- legacy API: telescope's buffer previewer isn't updated for the new "main" rewrite
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    ensure_installed = { "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "python", "bash" },
    highlight = { enable = true },
    indent = { enable = true },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}

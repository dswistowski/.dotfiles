require'nvim-treesitter.configs'.setup {
--   ensure_installed = { "javascript", "typescript", "c", "lua", "rust", "python", "gitignore", "go", "html", "css", "yaml", "toml", "bash", "markdown" },
   sync_install = false,
   auto_install = true,
   highlight = {
        enable = true,
        disable = {},
        additional_vim_regex_highlighting = false,
    },
}


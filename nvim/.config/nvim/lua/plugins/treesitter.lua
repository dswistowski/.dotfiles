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

    -- Workaround for https://github.com/neovim/neovim/issues/39032: the
    -- markdown `(#set! conceal_lines "")` predicate crashes with "attempt to
    -- call method 'range' (a nil value)" on fenced code blocks in Neovim
    -- 0.12.x. Strip it from the query until the upstream fix ships.
    local ok, files = pcall(vim.treesitter.query.get_files, "markdown", "highlights")
    if ok and #files > 0 then
      local chunks = {}
      for _, file in ipairs(files) do
        local f = io.open(file, "r")
        if f then
          table.insert(chunks, f:read("*a"))
          f:close()
        end
      end
      local patched = table.concat(chunks, "\n"):gsub('%(#set!%s+conceal_lines%s+""%)', "")
      vim.treesitter.query.set("markdown", "highlights", patched)
    end
  end,
}

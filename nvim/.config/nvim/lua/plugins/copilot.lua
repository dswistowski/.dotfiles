return {
  {
    "github/copilot.vim",
    event = "InsertEnter", -- lazy-load when entering insert mode
    config = function()
      -- Keep Copilot from mapping <Tab> (as in your old config)
      vim.g.copilot_no_tab_map = true

      -- Map <C-J> in insert mode to copilot#Accept("\<CR>")
      -- Use expr = true so the mapping is evaluated as an expression.
      -- replace_keycodes = false preserves the literal \<CR> in the call
      vim.keymap.set(
        "i",
        "<C-J>",
        'copilot#Accept("\\<CR>")',
        { expr = true, replace_keycodes = false, desc = "Copilot: accept" }
      )
    end,
  },
}

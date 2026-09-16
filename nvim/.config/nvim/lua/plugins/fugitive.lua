return {
  "tpope/vim-fugitive",
  lazy = false,
  cmd = { "Git", "Gvdiffsplit", "Gclog", "Gblame" },
  keys = {
    { "<leader>gg", "<cmd>Git<cr>", desc = "Fugitive Git Status" },
  },
}

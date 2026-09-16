return {
  "al1-ce/just.nvim",
  cmd = { "JustSelect" },
  dependencies = {
    "nvim-lua/plenary.nvim", -- async jobs
    "al1-ce/jsfunc.nvim", -- extension library
  },
  opts = {},
  keys = {
    { "<leader>jj", "<cmd>JustSelect<CR>", desc = "Just Select" },
  },
}

return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  cmd = "Telescope",
  keys = {
    { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find Files" },
    { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Grep" },
    { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Buffers" },
    { "<leader>fr", function() require("telescope.builtin").oldfiles() end, desc = "Recent Files" },
    { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Help Tags" },
    { "<leader>fd", function() require("telescope.builtin").diagnostics() end, desc = "Diagnostics" },
    -- modified, staged and untracked files (git status)
    { "<leader>fc", function() require("telescope.builtin").git_status() end, desc = "Changed Files" },
    {
      "<leader>fs",
      function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end,
      desc = "Workspace Symbols",
    },
  },
  config = function()
    require("telescope").setup {}
    pcall(require("telescope").load_extension, "fzf")
  end,
}

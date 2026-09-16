local map = vim.keymap.set

-- ergonomics
map("n", ";", ":", { desc = "Enter command mode" })
map("i", "jk", "<Esc>")

-- clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })

-- diagnostics
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

-- cheatsheet
map("n", "<leader>hh", function()
  require("cheatsheet").show()
end, { desc = "Show keymap cheatsheet" })

require("trouble").setup {
  position = "bottom", -- or "top", "left", "right"
  height = 10,
  width = 50,
  fold_open = "",
  fold_closed = "",
  use_diagnostic_signs = true, -- show LSP signs
}


vim.keymap.set("n", "<leader>xx", "<cmd>Trouble <cr>", { desc = "Toggle Trouble" })
vim.keymap.set("n", "<leader>xw", "<cmd>Trouble workspace_diagnostics<cr>", { desc = "Workspace Diagnostics" })
vim.keymap.set("n", "<leader>xd", "<cmd>Trouble document_diagnostics<cr>", { desc = "Document Diagnostics" })
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble quickfix<cr>", { desc = "Quickfix" })
vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist<cr>", { desc = "Location List" })


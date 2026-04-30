require("nvchad.mappings")

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<F2>", vim.diagnostic.goto_next)
map("n", "<leader>f", vim.lsp.buf.format)

map("i", "<S-Tab>", "<C-d>", { desc = "Decrease indent" })

map("n", "<leader>k", "<cmd>lnext<CR>zz")
map("n", "<leader>j", "<cmd>lprev<CR>zz")


map("n", "<leader>fs", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", { desc = "Search Workspace Symbols" })
map("n", "<leader>fS", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Search Document Symbols" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

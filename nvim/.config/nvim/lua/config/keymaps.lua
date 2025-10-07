vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("n", "<leader>n", vim.cmd.bnext)
vim.keymap.set("n", "<leader>b", vim.cmd.bprevious)

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
vim.keymap.set("n", "<F2>", vim.diagnostic.goto_next)

vim.keymap.set("n", "<C-Left>",  "<C-w>h")
vim.keymap.set("n", "<C-Down>",  "<C-w>j")
vim.keymap.set("n", "<C-Up>",    "<C-w>k")
vim.keymap.set("n", "<C-Right>", "<C-w>l")

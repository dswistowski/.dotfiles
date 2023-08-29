local neotest = require("neotest")

require("neotest").setup({
  adapters = {
    require("neotest-python")({
      dap = { justMyCode = false },
    }),
    require("neotest-plenary"),
    require("neotest-vim-test")({
      ignore_file_types = { "python", "vim", "lua" },
    }),
  },
})


vim.keymap.set('n', '<leader>tf', function() require("neotest").run.run(vim.fn.expand("%")) end, {})
vim.keymap.set('n', '<leader>tt', function() require("neotest").run.run(vim.fn.getcwd()) end, {})
vim.keymap.set('n', '<leader>tq', require("neotest").run.run, {})
vim.keymap.set('n', '<leader>tp', require("neotest").output_panel.toggle, {})
vim.keymap.set('n', '<leader>tr', function() require("neotest").output.open({ auto_exit = true; enter = true }) end,  {})
vim.keymap.set('n', '<leader>ts', function() require("neotest").summary.toggle() end,  {})
-- vim.keymap.set('n', '<leader>tq', function() require("neotest").quickfix end,  {})

vim.keymap.set('', '[n', function() require("neotest").jump.prev({ status = "failed" }) end, {})
vim.keymap.set('', ']n', function() require("neotest").jump.next({ status = "failed" }) end, {})
 

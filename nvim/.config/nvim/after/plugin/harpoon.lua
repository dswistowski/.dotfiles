local harpoon = require('harpoon.ui')
vim.keymap.set('n', '<leader>gg', harpoon.toggle_quick_menu, {})
vim.keymap.set('n', '<leader>ga', require("harpoon.mark").add_file, {})
vim.keymap.set('n', '[h', harpoon.nav_next, {})
vim.keymap.set('n', ']h', harpoon.nav_prev, {})
vim.keymap.set('n', '<leader>g1', function() harpoon.nav_file(1) end, {})
vim.keymap.set('n', '<leader>g2', function() harpoon.nav_file(2) end, {})
vim.keymap.set('n', '<leader>g3', function() harpoon.nav_file(3) end, {})
vim.keymap.set('n', '<leader>g4', function() harpoon.nav_file(4) end, {})
vim.keymap.set('n', '<leader>g5', function() harpoon.nav_file(5) end, {})
vim.keymap.set('n', '<leader>g6', function() harpoon.nav_file(6) end, {})
vim.keymap.set('n', '<leader>g7', function() harpoon.nav_file(7) end, {})
vim.keymap.set('n', '<leader>g8', function() harpoon.nav_file(8) end, {})

vim.keymap.set('n', '<leader>1', function() harpoon.nav_file(1) end, {})
vim.keymap.set('n', '<leader>2', function() harpoon.nav_file(2) end, {})
vim.keymap.set('n', '<leader>3', function() harpoon.nav_file(3) end, {})
vim.keymap.set('n', '<leader>4', function() harpoon.nav_file(4) end, {})
vim.keymap.set('n', '<leader>5', function() harpoon.nav_file(5) end, {})
vim.keymap.set('n', '<leader>6', function() harpoon.nav_file(6) end, {})
vim.keymap.set('n', '<leader>7', function() harpoon.nav_file(7) end, {})
vim.keymap.set('n', '<leader>8', function() harpoon.nav_file(8) end, {})



require("telescope").load_extension('harpoon')


local o = vim.o

o.number = true
o.relativenumber = true
o.cursorline = true
o.cursorlineopt = "both"
o.mouse = "a"
o.clipboard = "unnamedplus"

o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.breakindent = true
o.wrap = false

o.ignorecase = true
o.smartcase = true
o.inccommand = "split"

o.signcolumn = "yes"
o.scrolloff = 8
o.splitright = true
o.splitbelow = true

o.undofile = true
o.updatetime = 250
o.timeoutlen = 300

o.termguicolors = true
o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

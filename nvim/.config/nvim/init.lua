vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end
vim.opt.rtp:prepend(lazypath)

require "options"
require "autocmds"

require("lazy").setup {
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = false },
}

require "keymaps"

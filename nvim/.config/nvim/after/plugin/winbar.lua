local devicons = require("nvim-web-devicons")

-- Function to build winbar content
local function get_winbar()
  local filename = vim.fn.expand("%:t") -- just the filename
  if filename == "" then
    return "" -- no name for empty buffer
  end

  local extension = vim.fn.expand("%:e")
  local icon, icon_color = devicons.get_icon_color(filename, extension, { default = true })

  -- build with icon + filename
  local text = " " .. icon .. " " .. filename .. " "

  -- add highlight for the icon
  return "%#WinBar#" .. text
end

-- apply it
vim.o.winbar = "%{%v:lua.get_winbar()%}"

-- make function global
_G.get_winbar = get_winbar


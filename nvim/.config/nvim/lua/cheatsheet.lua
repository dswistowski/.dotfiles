local M = {}

-- Shows this config's README.md (the keymap cheatsheet) in a floating window.
function M.show()
  local path = vim.fn.stdpath "config" .. "/README.md"
  local lines = vim.fn.readfile(path)

  local width = math.min(90, vim.o.columns - 4)
  local height = math.min(#lines + 2, vim.o.lines - 4)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Keymap Cheatsheet ",
    title_pos = "center",
  })
  vim.wo[win].wrap = false

  local close = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  for _, key in ipairs { "q", "<Esc>" } do
    vim.keymap.set("n", key, close, { buffer = buf, nowait = true, desc = "Close cheatsheet" })
  end
end

return M

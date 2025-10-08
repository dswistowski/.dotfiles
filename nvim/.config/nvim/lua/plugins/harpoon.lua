return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
  lazy = false,
  config = function()
    local harpoon = require("harpoon")

    -- REQUIRED
    harpoon:setup()
    -- REQUIRED

    -- Add file
    vim.keymap.set("n", "<leader>la", function()
      harpoon:list():add()
    end, { desc = "Add to Harpoon" })

    -- Quick menu
    vim.keymap.set("n", "<leader>ll", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "Harpoon Menu" })

    -- Direct nav
    vim.keymap.set("n", "<leader>l1", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
    vim.keymap.set("n", "<leader>l2", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
    vim.keymap.set("n", "<leader>l3", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
    vim.keymap.set("n", "<leader>l3", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })

    -- Cycle
    vim.keymap.set("n", "<leader>l]", function() harpoon:list():prev() end, { desc = "Harpoon prev" })
    vim.keymap.set("n", "<leader>l[", function() harpoon:list():next() end, { desc = "Harpoon next" })
  end,
}

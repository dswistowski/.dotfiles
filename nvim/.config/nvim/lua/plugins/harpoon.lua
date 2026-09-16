return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>la", function() require("harpoon"):list():add() end, desc = "Harpoon Add File" },
    {
      "<leader>ll",
      function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end,
      desc = "Harpoon Menu",
    },
    { "<leader>l1", function() require("harpoon"):list():select(1) end, desc = "Harpoon File 1" },
    { "<leader>l2", function() require("harpoon"):list():select(2) end, desc = "Harpoon File 2" },
    { "<leader>l3", function() require("harpoon"):list():select(3) end, desc = "Harpoon File 3" },
    { "<leader>l4", function() require("harpoon"):list():select(4) end, desc = "Harpoon File 4" },
    { "<leader>l]", function() require("harpoon"):list():next() end, desc = "Harpoon Next" },
    { "<leader>l[", function() require("harpoon"):list():prev() end, desc = "Harpoon Previous" },
  },
  config = function()
    require("harpoon"):setup()
  end,
}

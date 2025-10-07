return {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },

  keys = {
    {
      "<leader>ff",
      "<cmd>Telescope find_files<cr>",
      desc = "Telescope find files",
    },
    {
	    "<leader>fg",
	    "<cmd>Telescope live_grep<cr>",
	    desc="Telescope live grep"
    },
    {
	    "<leader>fb",
	    "<cmd>Telescope buffers<cr>",
	    desc = "Telescope buffers"
    },
    {
	    "<leader>fh",
	    "<cmd>Telescope help tags<cr>",
	    desc = "Telescope help tags"
    },
}
}


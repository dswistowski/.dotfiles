return {
	---@module 'python'
	{
		"joshzcold/python.nvim",
		lazy = false,
		dependencies = {
			{ "mfussenegger/nvim-dap" },
			{ "mfussenegger/nvim-dap-python" },
			{ "neovim/nvim-lspconfig" },
			{ "L3MON4D3/LuaSnip" },
			{ "nvim-neotest/neotest" },
			{ "nvim-neotest/neotest-python" },
		},
		---@type python.Config
		opts = {
			-- Should return a list of tables with a `name` and a `path` entry each.
			-- Gets the argument `venvs_path` set below.
			-- By default just lists the entries in `venvs_path`.
			---@return VEnv[]
			get_venvs = function(venvs_path)
        local utils = require("python.venv")
        local venvs = utils.get_venvs(venvs_path) or {}
        local function find_upwards_dir(target_dir)
          local current_dir = vim.fn.getcwd()
          while current_dir and current_dir ~= "/" do
            local potential_path = vim.fs.joinpath(current_dir, target_dir)
            if vim.fn.isdirectory(potential_path) == 1 then
              return potential_path
            end
            current_dir = vim.fs.dirname(current_dir)
          end
          return nil
        end
        local project_venv = find_upwards_dir(".venv")
        if project_venv then
          table.insert(venvs, 1, { name = ".venv (project)", path = project_venv })
        end
        return venvs

			end,
			-- Path for venvs picker
			venvs_path = vim.fn.expand("~/.virtualenvs"),
			-- Something to do after setting an environment
			post_set_venv = nil,
			-- base path for creating new venvs
			auto_create_venv_path = function(parent_dir)
				return vim.fs.joinpath(parent_dir, ".venv")
			end,
			-- Patterns for autocmd LspAttach that trigger the auto venv logic
			-- Add onto this list if you depend on venvs for other file types
			-- like .yaml, .yml for ansible
			auto_venv_lsp_attach_patterns = { "*.py" },

			-- Buffer patterns to activate commands for python.nvim
			command_setup_buf_pattern = { "*.py" },

			-- Load python.nvim python snippets
			python_lua_snippets = false,

			-- List of text actions to take on InsertLeave, TextChanged
			-- Put in empty table or nil to disable
			enabled_text_actions = {
				"f-strings", -- When inserting {}, put in an f-string
			},
			-- Adjust when enabled_text_actions is triggered
			enabled_text_actions_autocmd_events = { "InsertLeave" },

			treesitter = {
				functions = {
					-- Wrap treesitter identifier under cursor using substitute_options
					wrapper = {
						-- Substitute options for PythonTSWrapWithFunc
						substitute_options = {
							"print(%s)",
							"log.debug(%s)",
							"log.info(%s)",
							"log.warning(%s)",
							"log.error(%s)",
							"np.array(%s)",
						},

						-- Look for tree-sitter types to wrap
						find_types = {
							"tuple",
							"string",
							"true",
							"false",
							"list",
							"call",
							"parenthesized_expression",
							"expression_statement",
							"integer",
						},
					},
				},
			},
			-- Load python keymaps. Everything starting with <leader>p...
			keymaps = {
				-- following nvim_set_keymap() mode, lhs, rhs, opts
				mappings = {
					["<leader>pv"] = { "n", "<cmd>Python venv pick<cr>", { desc = "python.nvim: pick venv" } },
					["<leader>pi"] = {
						"n",
						"<cmd>Python venv install<cr>",
						{ desc = "python.nvim: python venv install" },
					},
					["<leader>pd"] = { "n", "<cmd>Python dap<cr>", { desc = "python.nvim: python run debug program" } },

					-- Test Actions
					["<leader>ptt"] = {
						"n",
						"<cmd>Python test test<cr>",
						{ desc = "python.nvim: python run test suite" },
					},
					["<leader>ptm"] = {
						"n",
						"<cmd>Python test test_method<cr>",
						{ desc = "python.nvim: python run test method" },
					},
					["<leader>ptf"] = {
						"n",
						"<cmd>Python test test_file<cr>",
						{ desc = "python.nvim: python run test file" },
					},
					["<leader>ptdd"] = {
						"n",
						"<cmd>Python test test_debug<cr>",
						{ desc = "python.nvim: run test suite in debug mode." },
					},
					["<leader>ptdm"] = {
						"n",
						"<cmd>Python test test_method_debug<cr>",
						{ desc = "python.nvim: run test method in debug mode." },
					},
					["<leader>ptdf"] = {
						"n",
						"<cmd>Python test_file_debug<cr>",
						{ desc = "python.nvim: run test file in debug mode." },
					},

					-- VEnv Actions
					["<leader>ped"] = {
						"n",
						"<cmd>Python venv delete_select<cr>",
						{ desc = "python.nvim: select and delete a known venv." },
					},
					["<leader>peD"] = {
						"n",
						"<cmd>Python venv delete<cr>",
						{ desc = "python.nvim: delete current venv set." },
					},

					-- Language Actions
					["<leader>ppe"] = {
						"n",
						"<cmd>Python treesitter toggle_enumerate<cr>",
						{ desc = "python.nvim: turn list into enumerate" },
					},
					["<leader>ppw"] = {
						"n",
						"<cmd>Python treesitter wrap_cursor<cr>",
						{ desc = "python.nvim: wrap treesitter identifier with pattern" },
					},
					["<leader>pw"] = {
						"v",
						":Python treesitter wrap_cursor<cr>",
						{ desc = "python.nvim: wrap treesitter identifier with pattern" },
					},
				},
			},
			-- Settings regarding ui handling
			ui = {
				-- Amount of time to pause closing of ui after a finished task
				ui_close_timeout = 5000,

				-- Default ui style for interfaces created by python.nvim
				---@alias python_ui_default_style "'popup'|'split'|nil"
				default_ui_style = "popup",

				-- Customize the position and behavior of the ui style
				popup = {
					win_opts = {
						-- border = "rounded",
						-- relative = "win",
						-- focusable = true,
						-- title = "python.nvim",
						-- anchor = "SE",
						-- zindex = 999,
						-- width = 40,
						-- height = 20,
						-- row = vim.o.lines - 3,
						-- col = vim.o.columns -2,
					},
				},
				split = {
					win_opts = {
						-- split = 'below',
						-- win = 0,
						-- width = 40,
						-- height = 10,
						-- focusable = true,
					},
				},
			},

			-- Tell neotest-python which test runner to use
			test = {
				test_runner = "pytest",
			},
		},
	},
}

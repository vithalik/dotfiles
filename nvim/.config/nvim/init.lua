local opt = vim.o
local cmd = vim.cmd
local map = vim.keymap.set
local hl = vim.api.nvim_set_hl
local autocmd = vim.api.nvim_create_autocmd

vim.g.mapleader = " "

opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
opt.winborder = "rounded"
opt.breakindent = true
opt.clipboard = "unnamedplus"
opt.completeopt = "menuone,noselect"
opt.expandtab = false
opt.hlsearch = false
opt.ignorecase = true
opt.inccommand = "split"
opt.mouse = "a"
opt.number = true
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.relativenumber = true
opt.scrolloff = 10
opt.shiftround = true
opt.shiftwidth = 4
opt.showmode = false
opt.signcolumn = "yes"
opt.smartcase = true
opt.smartindent = true
opt.softtabstop = 4
opt.spell = false
opt.splitright = true
opt.swapfile = false
opt.tabstop = 4
opt.termguicolors = true
opt.timeoutlen = 500
opt.undofile = true
opt.updatetime = 200
opt.laststatus = 3
opt.foldcolumn = "0"
opt.foldlevel = 99
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.lsp.foldexpr()"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local servers = {
	bashls = {},
	clangd = { filetypes = { "c", "cpp", "arduino", "h", "hpp" } },
	html = {},
	jsonls = {},
	lua_ls = { settings = { Lua = { diagnostics = { globals = { "vim" } } } } },
	marksman = {},
	basedpyright = {
		settings = {
			basedpyright = {
				disableOrganizeImports = true,
				analysis = {
					ignore = { "*" },
					typeCheckingMode = "off",
					inlayHints = {
						callArgumentNames = false,
						functionReturnTypes = false,
						genericTypes = false,
						variableTypes = false,
					},
				},
			},
		},
	},
	ty = {},
	ruff = {},
	sqls = {},
	tailwindcss = {},
	vtsls = {},
	yamlls = {},
}

local formatters = {
	"kulala-fmt",
	"rustywind",
	"shfmt",
	"stylua",
	"taplo",
	"prettierd",
}

local linters = {
	"jsonlint",
	"shellcheck",
	"oxlint",
}

local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, formatters)
vim.list_extend(ensure_installed, linters)

require("lazy").setup({

	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				auto_install = true,
				highlight = { enable = true },
				indent = { enable = true },
				incremental_selection = {
					enable = true,
					keymaps = {
						node_incremental = "v",
						node_decremental = "V",
					},
				},
			})
		end,
	},

	{
		"ravsii/tree-sitter-d2",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		build = "make nvim-install",
	},

	{
		"stevearc/oil.nvim",
		lazy = false,
		opts = {
			use_default_keymaps = false,
			keymaps = {
				["<CR>"] = "actions.select",
				["-"] = { "actions.parent", mode = "n" },
				["<C-c>"] = { "actions.close", mode = "n" },
			},
			view_options = {
				show_hidden = true,
			},
		},
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	{
		"Mofiqul/dracula.nvim",
		opts = {
			colors = {
				black = "None",
				white = "None",
				bg = "None",
				menu = "None",
				comment = "#777777",
				selection = "#2D2D2D",
				visual = "#2D2D2D",
			},
			italic_comment = true,
			overrides = {
				LspInlayHint = { fg = "#777777", bg = "None", italic = true },
			},
		},
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim" },
			{ "mason-org/mason-lspconfig.nvim" },
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				opts = {
					ensure_installed = ensure_installed,
					auto_update = true,
				},
			},

			{
				"stevearc/conform.nvim",
				config = function()
					require("conform").setup({
						format_on_save = {
							timeout_ms = 500,
							lsp_fallback = true,
						},
						formatters = {
							deno_fmt = { append_args = { "--use-tabs", "--line-width=90" } },
							caddy = {
								command = "caddy",
								args = { "fmt", "-" },
								stdin = true,
							},
							prettierd = {
								append_args = {
									"--config-precedence=file-override",
									"--print-width=90",
									"--use-tabs=true",
								},
							},
						},
						formatters_by_ft = {
							astro = { "deno_fmt", "rustywind" },
							c = { "clang-format" },
							caddy = { "caddy" },
							cpp = { "clang-format" },
							css = { "deno_fmt" },
							d2 = { "d2" },
							go = { "gofumpt" },
							html = { "deno_fmt" },
							http = { "kulala-fmt" },
							ino = { "clang-format" },
							javascript = { "prettierd", "rustywind" },
							json = { "deno_fmt" },
							jsonc = { "deno_fmt" },
							lua = { "stylua" },
							markdown = { "deno_fmt" },
							nix = { "nixpkgs_fmt" },
							php = { "php_cs_fixer" },
							python = { "ruff_format", "ruff_organize_imports" },
							ruby = { "rubyfmt" },
							sql = { "pg_format" },
							svelte = { "prettierd", "rustywind" },
							swift = { "swiftformat" },
							templ = { "templ", "rustywind" },
							toml = { "taplo" },
							typescript = { "prettierd", "rustywind" },
							yaml = { "deno_fmt" },
						},
					})
				end,
			},

			{
				"mfussenegger/nvim-lint",
				config = function()
					local lint = require("lint")
					lint.linters.oxlint.args = {
						"--format",
						"unix",
						"-D",
						"suspicious",
						"-D",
						"perf",
					}
					lint.linters_by_ft = {
						go = { "golangcilint" },
						json = { "jsonlint" },
						php = { "phpstan" },
						svelte = { "oxlint" },
						javascript = { "oxlint" },
						typescript = { "oxlint" },
						javascriptreact = { "oxlint" },
						typescriptreact = { "oxlint" },
					}

					-- Create autocommand which carries out the actual linting
					-- on the specified events.
					local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
					vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
						group = lint_augroup,
						callback = function()
							require("lint").try_lint()
						end,
					})
				end,
			},
		},
	},

	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = {
			{ "rafamadriz/friendly-snippets" },
		},
		opts = {
			keymap = { preset = "default" },

			appearance = {
				nerd_font_variant = "normal",
			},

			completion = {
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
				},
			},

			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},

			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
		opts_extend = { "sources.default" },
	},

	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "-" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},

	{
		"catgoose/nvim-colorizer.lua",
		opts = {
			user_default_options = {
				tailwind = "both",
			},
		},
	},

	{ "echasnovski/mini.surround", version = "*", opts = {} },

	{
		"rmagatti/auto-session",
		lazy = false,
		opts = {
			suppressed_dirs = { "/", "~/", "~/Desktop/", "~/Downloads" },
		},
	},

	{ "smjonas/inc-rename.nvim", opts = {} },

	{ "hiphish/rainbow-delimiters.nvim" },

	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")

			map("n", "<leader>a", function()
				harpoon:list():add()
			end)
			map("n", "<leader>hb", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end)
			map("n", "<leader>j", function()
				harpoon:list():select(1)
			end)
			map("n", "<leader>k", function()
				harpoon:list():select(2)
			end)
			map("n", "<leader>l", function()
				harpoon:list():select(3)
			end)
			map("n", "<leader>;", function()
				harpoon:list():select(4)
			end)
		end,
	},

	{
		"codethread/qmk.nvim",
		lazy = true,
		config = function()
			local conf = {
				name = "ikiosuru",
				layout = {
					"x x x x x x _ x x x x x x",
					"x x x x x x _ x x x x x x",
					"x x x x x x _ x x x x x x",
					"_ _ _ x x x _ x x x _ _ _",
				},
				variant = "zmk",
			}
			require("qmk").setup(conf)
		end,
	},

	{
		"mistweaverco/kulala.nvim",
		version = "*",
		ft = { "http", "rest" },
		opts = {
			global_keymaps = true,
		},
	},

	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			bigfile = {},
			dim = {},
			explorer = {},
			indent = {
				animate = { enabled = false },
				filter = function(buf)
					local excluded_filetypes = { markdown = true }
					return vim.g.snacks_indent ~= false
						and vim.b[buf].snacks_indent ~= false
						and vim.bo[buf].buftype == ""
						and not excluded_filetypes[vim.bo[buf].filetype]
				end,
			},
			input = {},
			picker = {},
			lazygit = {},
			notifier = {},
			rename = {},
		},
		keys = {
			-- Top Pickers & Explorer
			{
				"<leader><space>",
				function()
					Snacks.picker.smart()
				end,
				desc = "Smart Find Files",
			},
			{
				"<leader>,",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>/",
				function()
					Snacks.picker.grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>:",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader>n",
				function()
					Snacks.picker.notifications()
				end,
				desc = "Notification History",
			},
			{
				"<leader>e",
				function()
					Snacks.explorer()
				end,
				desc = "File Explorer",
			},
			--find
			{
				"<leader>ff",
				function()
					Snacks.picker.files()
				end,
				desc = "Find Files",
			},
			{
				"<leader>fg",
				function()
					Snacks.picker.git_files()
				end,
				desc = "Find Git Files",
			},
			-- git
			{
				"<leader>gb",
				function()
					Snacks.picker.git_branches()
				end,
				desc = "Git Branches",
			},
			{
				"<leader>gl",
				function()
					Snacks.picker.git_log()
				end,
				desc = "Git Log",
			},
			{
				"<leader>gs",
				function()
					Snacks.picker.git_status()
				end,
				desc = "Git Status",
			},
			{
				"<leader>gS",
				function()
					Snacks.picker.git_stash()
				end,
				desc = "Git Stash",
			},
			-- Grep
			{
				"<leader>sg",
				function()
					Snacks.picker.grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>sw",
				function()
					Snacks.picker.grep_word()
				end,
				desc = "Visual selection or word",
				mode = { "n", "x" },
			},
			-- search
			{
				'<leader>s"',
				function()
					Snacks.picker.registers()
				end,
				desc = "Registers",
			},
			{
				"<leader>s/",
				function()
					Snacks.picker.search_history()
				end,
				desc = "Search History",
			},
			{
				"<leader>sb",
				function()
					Snacks.picker.lines()
				end,
				desc = "Buffer Lines",
			},
			{
				"<leader>sc",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader>sC",
				function()
					Snacks.picker.commands()
				end,
				desc = "Commands",
			},
			{
				"<leader>sd",
				function()
					Snacks.picker.diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				"<leader>sD",
				function()
					Snacks.picker.diagnostics_buffer()
				end,
				desc = "Buffer Diagnostics",
			},
			{
				"<leader>sh",
				function()
					Snacks.picker.help()
				end,
				desc = "Help Pages",
			},
			{
				"<leader>sH",
				function()
					Snacks.picker.highlights()
				end,
				desc = "Highlights",
			},
			{
				"<leader>si",
				function()
					Snacks.picker.icons()
				end,
				desc = "Icons",
			},
			{
				"<leader>sj",
				function()
					Snacks.picker.jumps()
				end,
				desc = "Jumps",
			},
			{
				"<leader>sk",
				function()
					Snacks.picker.keymaps()
				end,
				desc = "Keymaps",
			},
			{
				"<leader>sl",
				function()
					Snacks.picker.loclist()
				end,
				desc = "Location List",
			},
			{
				"<leader>sm",
				function()
					Snacks.picker.marks()
				end,
				desc = "Marks",
			},
			{
				"<leader>sM",
				function()
					Snacks.picker.man()
				end,
				desc = "Man Pages",
			},
			{
				"<leader>sq",
				function()
					Snacks.picker.qflist()
				end,
				desc = "Quickfix List",
			},
			{
				"<leader>sR",
				function()
					Snacks.picker.resume()
				end,
				desc = "Resume",
			},
			{
				"<leader>su",
				function()
					Snacks.picker.undo()
				end,
				desc = "Undo History",
			},
			{
				"<leader>uC",
				function()
					Snacks.picker.colorschemes()
				end,
				desc = "Colorschemes",
			},
			-- LSP
			{
				"gd",
				function()
					Snacks.picker.lsp_definitions()
				end,
				desc = "Goto Definition",
			},
			{
				"gD",
				function()
					Snacks.picker.lsp_declarations()
				end,
				desc = "Goto Declaration",
			},
			{
				"gr",
				function()
					Snacks.picker.lsp_references()
				end,
				nowait = true,
				desc = "References",
			},
			{
				"gI",
				function()
					Snacks.picker.lsp_implementations()
				end,
				desc = "Goto Implementation",
			},
			{
				"gy",
				function()
					Snacks.picker.lsp_type_definitions()
				end,
				desc = "Goto T[y]pe Definition",
			},
			-- Other
			{
				"<leader>z",
				function()
					Snacks.zen()
				end,
				desc = "Toggle Zen Mode",
			},
			{
				"<leader>.",
				function()
					Snacks.scratch()
				end,
				desc = "Toggle Scratch Buffer",
			},
			{
				"<leader>S",
				function()
					Snacks.scratch.select()
				end,
				desc = "Select Scratch Buffer",
			},
			{
				"<leader>n",
				function()
					Snacks.notifier.show_history()
				end,
				desc = "Notification History",
			},
			{
				"<leader>bd",
				function()
					Snacks.bufdelete()
				end,
				desc = "Delete Buffer",
			},
			{
				"<leader>cR",
				function()
					Snacks.rename.rename_file()
				end,
				desc = "Rename File",
			},
			{
				"<leader>gB",
				function()
					Snacks.gitbrowse()
				end,
				desc = "Git Browse",
				mode = { "n", "v" },
			},
			{
				"<leader>gg",
				function()
					Snacks.lazygit()
				end,
				desc = "Lazygit",
			},
			{
				"<leader>un",
				function()
					Snacks.notifier.hide()
				end,
				desc = "Dismiss All Notifications",
			},
		},
	},

	{
		"echasnovski/mini.statusline",
		version = false,
		config = function()
			local statusline = require("mini.statusline")
			statusline.section_location = function()
				return "%2l:%-2v"
			end
			statusline.section_filename = function()
				return vim.fn.expand("%:.")
			end
			statusline.section_fileinfo = function()
				local filetype = vim.bo.filetype
				local icon = require("nvim-web-devicons").get_icon(vim.fn.expand("%:t"), nil, { default = true })
				filetype = icon .. " " .. filetype
				return filetype
			end
			statusline.setup()
		end,
	},
}, {
	ui = {
		border = "rounded",
	},
})

cmd.colorscheme("dracula")

autocmd("FileType", {
	command = "set formatoptions-=cro",
})

for server_name, config in pairs(servers) do
	vim.lsp.config(server_name, config)
end

require("mason").setup()
require("mason-lspconfig").setup()

map("n", "K", vim.lsp.buf.hover)

map({ "n", "i" }, "<MiddleMouse>", "<Nop>")
map({ "n", "i", "v" }, "<RightMouse>", "<Nop>")
map({ "n", "i", "v" }, "<S-RightMouse>", "<Nop>")

map("n", "<C-h>", "<C-w><C-h>")
map("n", "<C-j>", "<C-w><C-j>")
map("n", "<C-k>", "<C-w><C-k>")
map("n", "<C-l>", "<C-w><C-l>")

map("n", "<C-d>", "0<C-d>zz")
map("n", "<C-u>", "0<C-u>zz")
map("n", "G", "0Gzz")
map("n", "N", "Nzz")
map("n", "n", "nzz")
map({ "n", "v" }, "<Space>", "<Nop>")
map("n", "<C-a>", "ggVG")
map({ "i", "c" }, "<C-v>", "<C-R><C-R>+")

map("n", "<C-s>", ":w<CR>")
map({ "i", "v", "c" }, "<C-s>", "<Esc>:w<CR>")

map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

map("n", "-", "<CMD>Oil<CR>")

map("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
map("v", "K", ":m '<-2<CR>gv=gv", { silent = true })

map("n", "<leader>rn", ":IncRename ")

map("n", "<C-f>", "<CMD>silent !tmux neww tmux-sessionizer<CR>")

-- Diagnostic keymaps
map("n", "[d", vim.diagnostic.goto_prev)
map("n", "]d", vim.diagnostic.goto_next)
map("n", "<leader>d", vim.diagnostic.open_float)

hl(0, "YankHighlight", { fg = "#131412", bg = "#E2E3E3" })
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({ higroup = "YankHighlight" })
	end,
	group = highlight_group,
	pattern = "*",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "ikiosuru.py",
	callback = function()
		vim.diagnostic.enable(false)
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = ".env",
	callback = function(args)
		vim.diagnostic.enable(false, args)
	end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
	callback = function()
		os.execute("hyprctl switchxkblayout current 0 >/dev/null 2>&1")
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "OilActionsPost",
	callback = function(event)
		if event.data.actions.type == "move" then
			Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
		end
	end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = { "Caddyfile", "*/Caddyfile", "*Caddyfile*" },
	callback = function()
		vim.bo.filetype = "caddy"
	end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = { "*.d2" },
	callback = function()
		vim.bo.filetype = "d2"
	end,
})

vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", {
	fg = "#111111",
	bg = "#bd93f9",
	bold = true,
})

vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual", {
	fg = "#111111",
	bg = "#ff79c6",
	bold = true,
})

vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert", {
	fg = "#111111",
	bg = "#50fa7b",
	bold = true,
})

vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", {
	fg = "#111111",
	bg = "#8be9fd",
	bold = true,
})

vim.api.nvim_set_hl(0, "MiniStatuslineModeReplace", {
	fg = "#111111",
	bg = "#f1fa8c",
	bold = true,
})

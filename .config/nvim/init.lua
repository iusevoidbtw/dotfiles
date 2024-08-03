local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')

Plug('catppuccin/nvim', { ['as'] = 'catppuccin' })

vim.g.coq_settings = { auto_start = 'shut-up', ['keymap.eval_snips'] = '<leader>j' }
Plug('ms-jpq/coq_nvim', { ['branch'] = 'coq' })
Plug('ms-jpq/coq.artifacts', { ['branch'] = 'artifacts' })

vim.g.chadtree_settings = {
	theme = {
		text_colour_set = 'nerdtree_syntax_dark'
	},
	keymap = {
		change_focus = {'l'},
		change_focus_up = {'h'},
		new = {'b'}
	}
}
Plug('ms-jpq/chadtree', { ['branch'] = 'chad', ['do'] = 'python3 -m chadtree deps'})

Plug('tpope/vim-fugitive')

vim.call('plug#end')

vim.cmd('colorscheme catppuccin-mocha')

-- keybinds

local function map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend('force', options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- quick keybinds
map('n', '<leader>s', ':w<cr>') -- save
map('n', '<leader>q', ':qa!<cr>') -- quit
map('n', '<leader>t', ':CHADopen<cr>') -- open chadtree
map('n', '<leader>y', ':abo vnew term://zsh<cr>') -- open zsh
map('n', '<leader>c', ':nohl<cr>') -- clear search highlighting
map('n', '<leader>n', '<esc>A;<esc>') -- add semicolon to end of line
map('n', '<leader>e', ':%s/    /	/g<cr>') -- replace 4 spaces with tabs

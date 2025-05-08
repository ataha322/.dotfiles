vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "number"
-- vim.opt.colorcolumn = "120"

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.compatible = false

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.clipboard = 'unnamedplus'
vim.opt.swapfile = false

vim.g.netrw_banner = false
vim.g.netrw_liststyle = 3

-- vim.opt.termguicolors = true

vim.g.have_nerd_font = true

vim.opt.incsearch = true
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.breakindent = true
vim.opt.mouse = 'a'
vim.opt.undofile = false
vim.opt.cursorline = true

vim.opt.completeopt:append({'noselect', 'fuzzy'})

vim.o.winborder = 'rounded'

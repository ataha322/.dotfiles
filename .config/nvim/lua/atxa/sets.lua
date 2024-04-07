vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.swapfile = false

vim.opt.incsearch = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "number"
-- vim.opt.colorcolumn = "120"

vim.opt.clipboard = 'unnamedplus'

vim.g.netrw_banner = false
vim.g.netrw_liststyle = 3

vim.opt.termguicolors = true

vim.cmd('command! -bar -nargs=* -complete=file -range=% -bang W <line1>,<line2>write<bang> <args>')

if os.getenv("NVIM") then
    -- for when already inside a neovim terminal
    vim.cmd("cquit")
end

local function load_env(path)
    local f = io.open(path, "r")
    if not f then return end
    for line in f:lines() do
        local key, value = line:match("^([^#][%w_]*)=(.+)$")
        if key then
            vim.fn.setenv(key, value)
        end
    end
    f:close()
end

load_env(vim.fn.stdpath("config") .. "/.env")

-- SECTION - CONFIG OPTIONS -----------------------------
vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
-- vim.opt.colorcolumn = "120"

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.clipboard = 'unnamedplus'
vim.opt.swapfile = false

vim.g.netrw_banner = false
vim.g.netrw_liststyle = 3

vim.g.have_nerd_font = true

vim.opt.incsearch = true
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.breakindent = true
vim.opt.mouse = ''
vim.opt.undofile = false
vim.opt.cursorline = true

vim.opt.winborder = 'rounded'

vim.opt.completeopt = 'noselect,fuzzy,popup,menuone'

vim.opt.foldlevel = 99

----------------------------------------------------------------------------
-- zero-setup plugins. rest of plugins under lua/plugins/
vim.pack.add({
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/tpope/vim-surround" },
    { src = "https://github.com/tpope/vim-sleuth" },
    { src = "https://github.com/sitiom/nvim-numbertoggle" },
    { src = "https://github.com/S1M0N38/ai.nvim" }, -- need for ata-ai-coding
})

-----------------------------------------------------------------------------
-- SECTION - KEY MAPPINGS -----------------------------------------
vim.keymap.set("n", "<leader>ee", function()
    vim.cmd("23Lex")
end)

-- keep cursor in place
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- delete to void
vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>p", "\"_dP")

-- replace all occurrences
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("v", "<leader>s", [[:s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- delete buffers
vim.keymap.set("n", "<leader>q", vim.cmd.bd)

-- move lines up and down
if vim.fn.has("mac") == 1 then
    -- macOS: use Cmd key
    vim.keymap.set("n", "<D-j>", ":m .+1<CR>==")
    vim.keymap.set("n", "<D-k>", ":m .-2<CR>==")
    vim.keymap.set("v", "<D-j>", ":m '>+1<CR>gv=gv")
    vim.keymap.set("v", "<D-k>", ":m '<-2<CR>gv=gv")
else
    -- Linux: use Alt key
    vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")
    vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")
    vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
    vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")
end

-- rename file in the current buffer
vim.keymap.set('n', '<leader>rr', function()
    local old_name = vim.fn.expand('%')

    if old_name == '' then
        vim.notify('No file to rename (buffer has no name)', vim.log.levels.WARN)
        return
    end

    local buftype = vim.bo.buftype
    if buftype ~= '' then
        vim.notify('Cannot rename: buffer is not a regular file (buftype: ' .. buftype .. ')', vim.log.levels.WARN)
        return
    end

    local new_name = vim.fn.input('New file name: ', old_name, 'file')
    if new_name ~= '' and new_name ~= old_name then
        vim.cmd('saveas ' .. new_name)
        vim.fn.delete(old_name)
    else
        vim.notify('Rename cancelled', vim.log.levels.WARN)
    end
end, { desc = 'Rename current file' })

-- highlight all occurrences of the word under cursor
vim.keymap.set("n", "<leader>h", function()
    local word = vim.fn.expand("<cword>")
    vim.cmd("let @/='" .. word .. "'")
    vim.cmd("set hlsearch")
end)
-- clear search highlights
vim.keymap.set("n", "<leader>nh", vim.cmd.nohlsearch)

-- delete all lines containing the word under cursor
vim.keymap.set("n", "<leader>wd", function()
    local word = vim.fn.expand("<cword>")
    if word == "" then return end
    vim.cmd("g/\\<" .. word .. "\\>/d")
end, { desc = "Delete all lines containing word under cursor" })

vim.keymap.set('n', '<leader>gs', function()
    local file = vim.fn.expand('%:p')
    vim.fn.system({ 'git', 'add', '--', file })
    vim.notify('git add -- ' .. vim.fn.fnamemodify(file, ':~:.'))
end)
vim.keymap.set('n', '<leader>gS', function()
    local file = vim.fn.expand('%:p')
    vim.fn.system({ 'git', 'restore', '--staged', '--', file })
    vim.notify('git restore --staged -- ' .. vim.fn.fnamemodify(file, ':~:.'))
end)

-- handle typos
vim.cmd([[cnoreabbrev <expr> W (getcmdtype() == ':' && getcmdline() == 'W') ? 'w' : 'W']])
vim.cmd([[cnoreabbrev <expr> Wq (getcmdtype() == ':' && getcmdline() == 'Wq') ? 'wq' : 'Wq']])
vim.cmd([[cnoreabbrev <expr> WQ (getcmdtype() == ':' && getcmdline() == 'WQ') ? 'wq' : 'WQ']])

vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function()
        -- Make help buffers listed and fullscreen
        if vim.bo.buftype == "help" then
            vim.bo.buflisted = true
            vim.cmd("only")
        end
    end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking',
    callback = function()
        vim.highlight.on_yank({ timeout = 300 })
    end,
})

-- Save and restore window view when switching buffers.
-- BufWin* rather than Buf*: those also fire when focusing a float (or any window) with another buffer,
-- which saved a view of the wrong window and restored it on return.
vim.api.nvim_create_autocmd({ 'BufWinLeave' }, {
    callback = function(args)
        if vim.bo[args.buf].buftype == '' then
            vim.b[args.buf].view = vim.fn.winsaveview()
        end
    end
})
vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
    callback = function(args)
        if vim.b[args.buf].view ~= nil then
            vim.fn.winrestview(vim.b[args.buf].view)
        end
    end
})

-- SECTION - MY PLUGINS DEVELOPMENT -----------------------------
-- AI plugin
require('ata-ai-coding').setup({
    inline_edit = {
        api_key = function()
            return vim.env.CEREBRAS_API_KEY
            -- return "asldkj"
            -- return vim.env.ZAI_API_KEY
        end,
        base_url = "https://api.cerebras.ai/v1",
        -- base_url = "https://api.z.ai/api/paas/v4",
        request = {
            model = "qwen-3.8-27b",
            -- model = "glm-5.3-flash",
        },
        log_level = vim.log.levels.WARN,
    },
})
vim.keymap.set('x', "<leader>ae", require('ata-ai-coding').inline_edit.prompt, {
    silent = true,
    desc = "Open inline-edit prompt",
})

-- note taking in neovim
vim.keymap.set("n", "<C-;>", function()
    require 'ata_notes'.toggle_notes_buffer("~/ATA_NOTES.md")
end, { desc = "Toggle global notes" })

vim.keymap.set("n", "<C-'>", function()
    require 'ata_notes'.toggle_notes_buffer(vim.fn.getcwd() .. "/ATA_NOTES.md")
end, { desc = "Toggle project notes" })
--------------------------------------------------------------------

require 'plugins'
require 'lsp'
require 'terminal'

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>ee", vim.cmd.Ex)
-- vim.keymap.set("n", "<leader>ee", function()
--     vim.cmd("19Lex")
-- end)

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

-- switch or delete buffers
vim.keymap.set("n", "<C-n>", vim.cmd.bn)
vim.keymap.set("n", "<C-p>", vim.cmd.bp)
vim.keymap.set("n", "<C-x>", vim.cmd.bd)

-- clear search highlights
vim.keymap.set("n", "<leader>nh", vim.cmd.nohlsearch)

-- manipulate CWD
vim.keymap.set("n", "<leader>gg", vim.cmd.pwd)
vim.keymap.set("n", "<leader>gw", function()
    vim.cmd.cd("%:h") -- cd to current working file directory
    vim.cmd.pwd()
end)
vim.keymap.set("n", "<leader>gs", function()
    vim.cmd.cd("..")
    vim.cmd.pwd()
end)

-- run python on buffer
vim.keymap.set("n", "<leader>py", function()
    vim.cmd("w ! python")
end)

-- run python on selected lines
vim.keymap.set("v", "<leader>py", function()
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")
    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end
    vim.api.nvim_out_write('\n') -- clear command line
    vim.cmd(start_line .. "," .. end_line .. "w ! python")
    -- go to normal mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), 'x', false)
end)

-- Map 'W' same as 'w'
vim.cmd('command! -bar -nargs=* -complete=file -range=% -bang W <line1>,<line2>write<bang> <args>')

-- Compile latex into pdf
vim.api.nvim_create_user_command("LL", function()
    local cmd_pdflatex = 'pdflatex -file-line-error -halt-on-error -interaction=nonstopmode '
    local cmd = cmd_pdflatex .. vim.fn.expand("%")
    vim.fn.systemlist(cmd)
    local exit_code = vim.v.shell_error

    if exit_code == 0 then
        vim.notify('Latex compiled')
    else
        vim.notify('Failed latex compile')
    end
end, {})

-- Make help buffers listed and fullscreen
vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = "*.txt",
    callback = function()
        if vim.bo.filetype == "help" then
            vim.bo.buflisted = true
            vim.cmd("only")
        end
    end,
})

-- Highlight when yanking
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking',
    callback = function()
        vim.highlight.on_yank({ timeout = 300 })
    end,
})

-- Nvim terminal in a separate unlisted buffer
vim.api.nvim_create_autocmd('TermOpen', {
    group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
    end,
})

local terminal_bufnr = nil
local work_bufnr = nil
local function toggle_terminal()
    local current_buf = vim.api.nvim_get_current_buf()

    if terminal_bufnr and vim.api.nvim_buf_is_valid(terminal_bufnr) then
        if current_buf == terminal_bufnr then
            if work_bufnr and vim.api.nvim_buf_is_valid(work_bufnr) then
                vim.cmd.buffer(work_bufnr)
            else
                vim.cmd.bp()
            end
        else
            work_bufnr = vim.api.nvim_get_current_buf()
            vim.cmd.buffer(terminal_bufnr)
        end
    else
        work_bufnr = vim.api.nvim_get_current_buf()
        terminal_bufnr = vim.api.nvim_create_buf(false, true) -- Unlisted scratch buffer
        vim.cmd.buffer(terminal_bufnr)
        vim.api.nvim_command('terminal')
        vim.bo[terminal_bufnr].buflisted = false -- set to unlisted because `terminal` sets to listed
    end
end

vim.keymap.set('n', '<leader>tt', toggle_terminal, { noremap = true, silent = true })
vim.keymap.set('t', '<esc><esc>', '<c-\\><c-n>')

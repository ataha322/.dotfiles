vim.g.mapleader = " "
-- vim.keymap.set("n", "<leader>ee", vim.cmd.Ex)
vim.keymap.set("n", "<leader>ee", function()
    vim.cmd("19Lex")
end)

-- keep cursor in place
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- delete to void
vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>p", "\"_dP")

-- replace all occurrences
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("v", "<leader>s", [[:s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- switch or delete buffers
vim.keymap.set("n", "<C-n>", vim.cmd.bn)
vim.keymap.set("n", "<C-p>", vim.cmd.bp)
vim.keymap.set("n", "<C-x>", vim.cmd.bd)

-- copy to clipboard current directory path
vim.api.nvim_create_user_command("Cpp", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})


-- compile latex into pdf
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

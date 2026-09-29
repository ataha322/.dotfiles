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

vim.keymap.set({ 'n', 'i', 't' }, '<C-\\>', toggle_terminal, { silent = true })
vim.keymap.set('t', '<c-x>', '<c-\\><c-n>')

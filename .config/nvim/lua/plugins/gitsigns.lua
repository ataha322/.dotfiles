vim.pack.add({
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
})

require("gitsigns").setup({
    current_line_blame = true,
    current_line_blame_opts = { delay = 0 },
    gh = true,
})

vim.keymap.set('n', '[c', function()
    if vim.wo.diff then
        vim.cmd.normal({ '[c', bang = true })
    else
        require 'gitsigns'.nav_hunk('prev', { target = 'all' })
    end
end)
vim.keymap.set('n', ']c', function()
    if vim.wo.diff then
        vim.cmd.normal({ ']c', bang = true })
    else
        require 'gitsigns'.nav_hunk('next', { target = 'all' })
    end
end)

vim.keymap.set('n', 'dO', require 'gitsigns'.stage_hunk)
vim.keymap.set('n', 'dp', require 'gitsigns'.reset_hunk)
vim.keymap.set('n', 'do', require 'gitsigns'.preview_hunk)
vim.keymap.set('n', '<leader>gb', function()
    require 'gitsigns'.blame_line({ full = true })
end)
vim.keymap.set('n', '<leader>gB', function()
    require 'gitsigns'.blame()
end)
vim.keymap.set('n', '<leader>gd', function()
    require 'gitsigns'.diffthis()
end)
vim.keymap.set('n', '<leader>gq', function()
    require 'gitsigns'.setqflist("all")
end)

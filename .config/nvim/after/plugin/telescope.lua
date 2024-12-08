local telescope = require('telescope')
local builtin = require('telescope.builtin')
local themes = require('telescope.themes')
local actions = require('telescope.actions')
telescope.setup({
    defaults = {
        preview = {
            timeout = 2000
        },
        mappings = {
            n = {
                ['<C-x>'] = actions.delete_buffer
            },
            i = {
                ['<C-x>'] = actions.delete_buffer
            }
        }
    }
})

function vim.getVisualSelection()
    vim.cmd('noau normal! "vy"')
    local text = vim.fn.getreg('v')
    vim.fn.setreg('v', {})

    text = string.gsub(text, "\n", "")
    if #text > 0 then
        return text
    else
        return ''
    end
end

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fw', builtin.grep_string, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fp', builtin.pickers, {})
vim.keymap.set('n', '<leader>fr', builtin.resume, {})
vim.keymap.set('n', '<leader>fc', builtin.colorscheme, {})
vim.keymap.set('n', '<leader><leader>', builtin.buffers, {})
vim.keymap.set('v', '<leader>fv', function()
    local text = vim.getVisualSelection()
    builtin.grep_string({ search = text })
end)
vim.keymap.set('n', '<leader>/', function()
    -- builtin.current_buffer_fuzzy_find(themes.get_cursor {
    builtin.current_buffer_fuzzy_find(themes.get_dropdown {
        previewer = false,
    })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.pack.add({
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
    { src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
})

require("telescope").setup({
    defaults = {
        preview = {
            timeout = 2000
        },
        mappings = {
            n = {
                ['<C-x>'] = require('telescope.actions').delete_buffer
            },
            i = {
                ['<C-x>'] = require('telescope.actions').delete_buffer,
            },
        },
        border = true,
        layout_strategy = 'horizontal',
        layout_config = {
            horizontal = {
                height = 0.95,
                preview_cutoff = 120,
                prompt_position = "bottom",
                width = 0.95
            },
            vertical = {
                height = 0.95,
                preview_cutoff = 40,
                prompt_position = "bottom",
                width = 0.95
            }
        },
        file_ignore_patterns = {
            "^node_modules/",
            "^dist/",
            "^%.next/",
            "^%.?venv/",
            "^%.mypy_cache/",
            "^%.pytest_cache/",
            "^__pycache__/",
            "^%.ruff_cache/",
            "^%.git/",
            "^target/",
        },
    },
    extensions = {
        ["ui-select"] = {
            require('telescope.themes').get_dropdown({
                previewer = false,
            })
        }
    }
})
require 'telescope'.load_extension("ui-select")

local function getVisualSelection()
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

vim.keymap.set('n', '<leader>gc', require('telescope.builtin').git_commits, {})
vim.keymap.set('n', '<leader>gg', require('telescope.builtin').git_status, {})
vim.keymap.set('n', '<leader>gl', function()
    require('telescope.builtin').git_branches(
        require('telescope.themes').get_dropdown({
            previewer = false,
        })
    )
end)

vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, {})
vim.keymap.set('n', '<leader>fw', require('telescope.builtin').grep_string, {})
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, {})
vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, {})
vim.keymap.set('n', '<leader>fr', require('telescope.builtin').resume, {})
vim.keymap.set('n', '<leader>fc', function()
    require('telescope.builtin').colorscheme(
        require('telescope.themes').get_dropdown({
            previewer = false,
        })
    )
end, {})
vim.keymap.set('n', '<leader><leader>', function()
    require('telescope.builtin').buffers(
        require('telescope.themes').get_dropdown({
            sort_mru = true,
            previewer = false,
        })
    )
end)
vim.keymap.set('v', '<leader>fv', function()
    require('telescope.builtin').grep_string({ search = getVisualSelection() })
end)
vim.keymap.set('n', '<leader>fo', function()
    require('telescope.builtin').oldfiles({ only_cwd = true })
end)
vim.keymap.set('n', '<leader>fq', require('telescope.builtin').quickfix)
vim.keymap.set('n', '<leader>fi', require('telescope.builtin').quickfixhistory)
vim.keymap.set('n', '<leader>fm', require('telescope.builtin').marks)
vim.keymap.set('n', '<leader>fd', function()
    require('telescope.builtin').diagnostics({
        bufnr = 0,
    })
end)
vim.keymap.set('n', '<leader>fD', function()
    require('telescope.builtin').diagnostics({
        bufnr = nil,
    })
end)
vim.keymap.set('n', '<leader>/', function()
    require('telescope.builtin').current_buffer_fuzzy_find(require 'telescope.themes'.get_dropdown({
        previewer = false,
    }))
end)
vim.keymap.set('n', '<leader>;', function()
    require('telescope.builtin').commands()
end)

vim.keymap.set('n', 'grr', require('telescope.builtin').lsp_references)
vim.keymap.set('n', 'gri', require('telescope.builtin').lsp_implementations)
vim.keymap.set('n', 'grd', require('telescope.builtin').lsp_definitions)
vim.keymap.set('n', 'grt', require('telescope.builtin').lsp_type_definitions)
vim.keymap.set('n', 'grc', require('telescope.builtin').lsp_incoming_calls)
vim.keymap.set('n', 'grC', require('telescope.builtin').lsp_outgoing_calls)

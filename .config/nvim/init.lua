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

vim.opt.completeopt:append({ 'noselect', 'fuzzy', 'popup', 'menuone' })

vim.opt.foldlevel = 99


vim.diagnostic.config({
    -- virtual_lines = { current_line = true },
    -- virtual_text = { current_line = true },
    jump = {
        float = true
    },
    update_in_insert = true,
})
-----------------------------------------------------------------------

vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
    { src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
    { src = "https://github.com/supermaven-inc/supermaven-nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/tpope/vim-surround" },
    { src = "https://github.com/tpope/vim-sleuth" },
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
    { src = "https://github.com/stevearc/conform.nvim" },
    { src = "https://github.com/rose-pine/neovim" },
})
-----------------------------------------------------------------------

require("nvim-treesitter").install({
    "c", "lua", "vim", "vimdoc", "query", "go", "python", "cpp",
    "javascript", "typescript", "diff", "jsonc",
    "json", "toml", "latex", "rust", "sql",
    "markdown", "markdown_inline", "html", "typst", "yaml",
})

vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        -- might want to pcall()
        vim.treesitter.start()

        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo[0][0].foldmethod = "expr"
    end,
})

require("nvim-treesitter-textobjects").setup({
    select = {
        lookahead = true,
    },
    move = {
        set_jumps = true,
    },
})

do
    local select = require("nvim-treesitter-textobjects.select")
    local move = require("nvim-treesitter-textobjects.move")

    vim.keymap.set({ "x", "o" }, "af", function() select.select_textobject("@function.outer", "textobjects") end)
    vim.keymap.set({ "x", "o" }, "if", function() select.select_textobject("@function.inner", "textobjects") end)
    vim.keymap.set({ "x", "o" }, "ac", function() select.select_textobject("@class.outer", "textobjects") end)
    vim.keymap.set({ "x", "o" }, "ic", function() select.select_textobject("@class.inner", "textobjects") end)

    vim.keymap.set({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer", "textobjects") end)
    vim.keymap.set({ "n", "x", "o" }, "]o", function() move.goto_next_start("@class.inner", "textobjects") end)
    vim.keymap.set({ "n", "x", "o" }, "]F", function() move.goto_next_end("@function.outer", "textobjects") end)
    vim.keymap.set({ "n", "x", "o" }, "]O", function() move.goto_next_end("@class.outer", "textobjects") end)

    vim.keymap.set({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end)
    vim.keymap.set({ "n", "x", "o" }, "[o", function() move.goto_previous_start("@class.inner", "textobjects") end)
    vim.keymap.set({ "n", "x", "o" }, "[F", function() move.goto_previous_end("@function.outer", "textobjects") end)
    vim.keymap.set({ "n", "x", "o" }, "[O", function() move.goto_previous_end("@class.outer", "textobjects") end)
end

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

require("supermaven-nvim").setup({
    keymaps = {
        accept_suggestion = "<C-f>",
        clear_suggestion = "<C-k>",
        accept_word = "<C-l>",
    },
})

require("gitsigns").setup({
    current_line_blame = true,
    current_line_blame_opts = { delay = 0 },
    gh = true,
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
require("conform").setup({
    formatters_by_ft = {
        markdown = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
    },
    formatters = {
        prettier = {
            prepend_args = function()
                return {
                    "--tab-width", "4",
                    "--print-width", "120",
                    "--config-precedence", "prefer-file",
                }
            end,
        },
    },
    default_format_opts = {
        lsp_format = "fallback",
    },
})

require("rose-pine").setup({
    styles = {
        transparency = true,
    },
})
-----------------------------------------------------------------------

-- SECTION - COLORSCHEME ----------------------------------------------
-- vim.cmd.colorscheme("rose-pine")
-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- vim.api.nvim_set_hl(0, "WinSeparator", { bg = "bg", fg = "#afaf8b" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "bg" })
-- vim.api.nvim_set_hl(0, "FloatBorder", { bg = "bg" })
-- vim.api.nvim_set_hl(0, "PMenu", { bg = "none"})
-----------------------------------------------------------------------

-- SECTION - Custom LSP settings (on top of nvim-lspconfig)
vim.lsp.config("basedpyright",
    {
        settings = {
            basedpyright = {
                analysis = {
                    diagnosticSeverityOverrides = {
                        reportAny = "none",
                        reportExplicitAny = "none",
                        reportUnannotatedClassAttribute = "none",
                        reportMissingTypeArgument = "none",
                        reportUnknownMemberType = "none",
                        reportUnknownVariableType = "none",
                    },
                },
            },
        },
    }
)

vim.lsp.enable({ 'ts_ls', 'basedpyright', 'gopls', 'lua_ls', 'rust_analyzer' })

-----------------------------------------------------------------------------
-- SECTION - KEY MAPPINGS -----------------------------------------
vim.keymap.set("n", "<leader>ee", function()
    if vim.bo.filetype ~= 'netrw' then
        vim.cmd.Ex()
    else
        vim.cmd.bp()
    end
end)
-- vim.keymap.set("n", "<leader>ee", function()
--     vim.cmd("23Lex")
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

vim.keymap.set('n', '<leader>gc', require('telescope.builtin').git_commits, {})
vim.keymap.set('n', '<leader>gg', require('telescope.builtin').git_status, {})
vim.keymap.set('n', '<leader>gl', function()
    require('telescope.builtin').git_branches(
        require('telescope.themes').get_dropdown({
            previewer = false,
        })
    )
end)
vim.keymap.set('n', '<leader>gb', function()
    require 'gitsigns'.blame_line({ full = true })
end)
vim.keymap.set('n', '<leader>gB', function()
    require 'gitsigns'.blame()
end)
vim.keymap.set('n', '<leader>gd', function()
    require 'gitsigns'.diffthis()
end)
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
vim.keymap.set('n', '<leader>gq', function()
    require 'gitsigns'.setqflist("all")
end)

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
vim.keymap.set('n', 'grk', vim.diagnostic.open_float)
vim.keymap.set("n", "grD", function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end)
vim.keymap.set('n', "grh", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end)

-- formatting
vim.keymap.set({ 'n', 'v' }, "grf", function()
    require('conform').format()
end)


-- Map 'W' same as 'w'
vim.cmd('command! -bar -nargs=* -complete=file -range=% -bang W <line1>,<line2>write<bang> <args>')

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

-- Save and restore window view when switching buffers
vim.api.nvim_create_autocmd({ 'BufLeave' }, {
    callback = function(args)
        if vim.bo[args.buf].buftype == '' then
            vim.b[args.buf].view = vim.fn.winsaveview()
        end
    end
})
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    callback = function(args)
        if vim.b[args.buf].view ~= nil then
            vim.fn.winrestview(vim.b[args.buf].view)
        end
    end
})

-- relative number line when normal, absolute when insert mode
vim.api.nvim_create_autocmd({ 'InsertEnter' }, {
    callback = function()
        if vim.bo.buftype == "" then
            vim.opt_local.relativenumber = false
        end
    end,
})
vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
    callback = function()
        if vim.bo.buftype == "" then
            vim.opt_local.relativenumber = true
        end
    end,
})



------------------------------------------------------------------
-- SECTION - TERMINAL
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

-- my own plugin development
require('inline-edit').setup({
    llm = {
        provider = "cerebras",
        model = "gemma-4-31b",
        reasoning_effort = "medium",
    },
    -- context = {
    --     more_selected_lines = 2,
    -- },
})
vim.keymap.set({ 'n', 'v' }, "<leader>ae", require('inline-edit').open_prompt, {
    silent = true,
    desc = "Open inline-edit prompt",
})

-- my own notes in neovim
vim.keymap.set("n", "<C-;>", function()
    require 'ata_notes'.toggle_notes_buffer("~/ATA_NOTES.md")
end, { desc = "Toggle global notes" })

vim.keymap.set("n", "<C-'>", function()
    require 'ata_notes'.toggle_notes_buffer(vim.fn.getcwd() .. "/ATA_NOTES.md")
end, { desc = "Toggle project notes" })

-- Bootstrap lazy.nvim -------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)
----------------------------------------------------------

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


vim.diagnostic.config({
    -- virtual_lines = { current_line = true },
    -- virtual_text = { current_line = true },
    jump = {
        float = true
    },
    update_in_insert = true,
})
-----------------------------------------------------------------------

-- SECTION - Setup lazy.nvim -------------------------------------------------
require("lazy").setup({
    git = {
        timeout = 3600,
    },
    spec = {
        {
            "nvim-treesitter/nvim-treesitter",
            branch = 'master',
            lazy = false,
            build = ":TSUpdate",
            dependencies = {
                {
                    'nvim-treesitter/nvim-treesitter-textobjects',
                    branch = 'master',
                    event = "VeryLazy",
                }
            },
            opts = function()
                require 'nvim-treesitter.configs'.setup {
                    -- A list of parser names, or "all" (the five listed parsers should always be installed)
                    ensure_installed = {
                        "c", "lua", "vim", "vimdoc", "query", "go", "python", "cpp",
                        "javascript", "typescript", "markdown", "markdown_inline", "diff", "jsonc",
                        "json", "yaml", "toml", "latex", "rust", "sql"
                    },

                    -- Install parsers synchronously (only applied to `ensure_installed`)
                    sync_install = false,

                    -- Automatically install missing parsers when entering buffer
                    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
                    auto_install = true,

                    highlight = {
                        enable = true,

                        -- Commenting out because nvim 0.11 is running treesitter asynchronously
                        --
                        -- Disable slow treesitter highlight for large files
                        -- disable = function(lang, buf)
                        --     local max_filesize = 1024 * 1024
                        --     local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        --     if ok and stats and stats.size > max_filesize then
                        --         return true
                        --     end
                        -- end,

                        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                        -- Using this option may slow down your editor, and you may see some duplicate highlights.
                        -- Instead of true it can also be a list of languages
                        additional_vim_regex_highlighting = false,
                    },

                    indent = {
                        enable = true
                    },

                    textobjects = {
                        select = {
                            enable = true,
                            lookahead = true,
                            keymaps = {
                                ['af'] = '@function.outer',
                                ['if'] = '@function.inner',
                                ['ac'] = '@class.outer',
                                ['ic'] = '@class.inner',
                            },
                        },
                        move = {
                            enable = true,
                            set_jumps = true,
                            goto_next_start = {
                                [']m'] = '@function.outer',
                                [']]'] = '@class.inner',
                            },
                            goto_next_end = {
                                [']M'] = '@function.outer',
                                [']['] = '@class.outer',
                            },
                            goto_previous_start = {
                                ['[m'] = '@function.outer',
                                ['[['] = '@class.inner',
                            },
                            goto_previous_end = {
                                ['[M'] = '@function.outer',
                                ['[]'] = '@class.outer',
                            },
                        },
                    }
                }
            end
        },
        {
            'nvim-telescope/telescope.nvim',
            tag = '0.1.8',
            dependencies = {
                'nvim-lua/plenary.nvim',
                'nvim-telescope/telescope-ui-select.nvim'
            },
            lazy = false,
            opts = function()
                return {
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
                    -- pickers = {
                    --     find_files = {
                    --         hidden = true,
                    --         no_ignore = true,
                    --         follow = true,
                    --     },
                    -- },
                    extensions = {
                        ["ui-select"] = {
                            require('telescope.themes').get_dropdown({
                                winblend = 7,
                                previewer = false,
                            })
                        }
                    }

                }
            end
        },
        {
            "supermaven-inc/supermaven-nvim",
            config = function()
                require("supermaven-nvim").setup({
                    keymaps = {
                        accept_suggestion = "<C-f>",
                        clear_suggestion = "<C-k>",
                        accept_word = "<C-l>",
                    },
                })
            end,
        },
        -- {
        --     'milanglacier/minuet-ai.nvim',
        --     config = function()
        --         require('minuet').setup {
        --             provider = 'openai_fim_compatible',
        --             n_completions = 1,
        --             context_window = 2048,
        --             provider_options = {
        --                 -- openai_fim_compatible = {
        --                 --     api_key = 'TERM',
        --                 --     name = 'Llama.cpp',
        --                 --     end_point = 'http://localhost:8012/v1/completions',
        --                 --     model = 'PLACEHOLDER',
        --                 --     optional = {
        --                 --         max_tokens = 56,
        --                 --         top_p = 0.9,
        --                 --     },
        --                 --     template = {
        --                 --         prompt = function(context_before_cursor, context_after_cursor, _)
        --                 --             return '<|fim_prefix|>'
        --                 --                 .. context_before_cursor
        --                 --                 .. '<|fim_suffix|>'
        --                 --                 .. context_after_cursor
        --                 --                 .. '<|fim_middle|>'
        --                 --         end,
        --                 --         suffix = false,
        --                 --     },
        --                 -- },
        --                 openai_fim_compatible = {
        --                     model = "mercury-coder",
        --                     end_point = "https://api.inceptionlabs.ai/v1/fim/completions",
        --                     api_key = "INCEPTION_API_KEY",
        --                     stream = true,
        --                 },
        --             },
        --             virtualtext = {
        --                 auto_trigger_ft = { 'python', 'lua', 'rust', 'typescript', 'javascript', 'javascriptreact', 'typescriptreact' },
        --                 -- auto_trigger_ft = {},
        --             },
        --         }
        --     end,
        --     event = "VeryLazy",
        -- },
        { 'neovim/nvim-lspconfig', lazy = false },
        { 'tpope/vim-surround',    event = "VeryLazy" },
        { 'tpope/vim-sleuth',      event = "VeryLazy" },
        {
            'lewis6991/gitsigns.nvim',
            event = "VeryLazy",
            opts = {
                current_line_blame = true,
                current_line_blame_opts = { delay = 100 },
                gh = true,
            }
        },
        {
            'stevearc/conform.nvim',
            event = "VeryLazy",
            opts = function()
                vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
                return {
                    formatters_by_ft = {
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
                }
            end
        },
        {
            "folke/sidekick.nvim",
            event = "VeryLazy",
            opts = {
                nes = {
                    enabled = false,
                    ---@class sidekick.diff.Opts
                    ---@field inline? "words"|"chars"|false Enable inline diffs
                    diff = {
                        inline = "words",
                    }
                },
                cli = {
                    win = {
                        layout = "float", ---@type "float"|"left"|"bottom"|"top"|"right"
                        ---@type vim.api.keyset.win_config
                        float = {
                            width = 0.75,
                            height = 0.75,
                        },
                        keys = {
                            hide_n = false,
                            hide_ctrl_q = false,
                            hide_ctrl_dot = false,
                            prompt = false,
                            stopinsert = false,
                        },
                    }
                },
            },
            keys = {
                {
                    "<c-.>",
                    function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end,
                    desc = "Sidekick Toggle Claude",
                    mode = { "n", "t", "i", "x" },
                },
                {
                    "<leader>at",
                    function() require("sidekick.cli").send({ msg = "{this}" }) end,
                    mode = { "x", "n" },
                    desc = "Send This",
                },
                {
                    "<leader>af",
                    function() require("sidekick.cli").send({ msg = "{file}" }) end,
                    desc = "Send File",
                },
                {
                    "<leader>av",
                    function() require("sidekick.cli").send({ msg = "{selection}" }) end,
                    mode = { "x" },
                    desc = "Send Visual Selection",
                },
                {
                    "<leader>ap",
                    function() require("sidekick.cli").prompt() end,
                    mode = { "n", "x" },
                    desc = "Sidekick Select Prompt",
                },
            },
        },
        {
            "rose-pine/neovim",
            name = "rose-pine",
            config = function()
                require("rose-pine").setup({
                    styles = {
                        transparency = true,
                    },
                })
            end,
        },
    },
    install = {},
    checker = { enabled = false },
})

require 'telescope'.load_extension("ui-select")

-- SECTION - COLORSCHEME ----------------------------------------------
vim.cmd.colorscheme("rose-pine")
-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- vim.api.nvim_set_hl(0, "WinSeparator", { bg = "bg", fg = "#afaf8b" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "bg" })
-- vim.api.nvim_set_hl(0, "FloatBorder", { bg = "bg" })
-- vim.api.nvim_set_hl(0, "PMenu", { bg = "none"})

-- rose-pine
-- murphy
-- retrobox
-- default
-- slate
-- gruvdark
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
-- vim.keymap.set("n", "<leader>ee", function()
--     if vim.bo.filetype ~= 'netrw' then
--         vim.cmd.Ex()
--     else
--         vim.cmd.bp()
--     end
-- end)
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

-- manipulate CWD
vim.keymap.set("n", "<leader>ww", vim.cmd.pwd)
vim.keymap.set("n", "<leader>wc", function()
    vim.cmd.cd("%:h") -- cd to current file directory
    vim.cmd.pwd()
end)
vim.keymap.set("n", "<leader>wb", function()
    vim.cmd.cd("..")
    vim.cmd.pwd()
end)

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
            winblend = 7,
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
            winblend = 7,
            previewer = false,
        })
    )
end, {})
vim.keymap.set('n', '<leader><leader>', function()
    require('telescope.builtin').buffers(
        require('telescope.themes').get_dropdown({
            sort_mru = true,
            winblend = 7,
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
        winblend = 7,
        previewer = false,
    }))
end)
-- TODO:
-- builtin.commands({opts})                        *telescope.builtin.commands()*
-- builtin.oldfiles({opts})                        *telescope.builtin.oldfiles()*
-- builtin.command_history({opts})          *telescope.builtin.command_history()*
-- builtin.search_history({opts})            *telescope.builtin.search_history()*
-- builtin.vim_options({opts})                  *telescope.builtin.vim_options()*

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

-- AI completion
-- vim.keymap.set('i', "<c-f>", function()
--     if require 'minuet.virtualtext'.action.is_visible() then
--         require 'minuet.virtualtext'.action.accept()
--     else
--         require 'minuet.virtualtext'.action.next()
--     end
-- end)
-- vim.keymap.set('i', "<c-l>", function()
--     require('minuet.virtualtext').action.accept_line()
-- end)
-- vim.keymap.set('i', "<c-k>", function()
--     require('minuet.virtualtext').action.dismiss()
-- end)

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

vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = "*.txt",
    callback = function()
        -- Make help buffers listed and fullscreen
        if vim.bo.filetype == "help" then
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
        if vim.bo[args.buf].buftype == '' or vim.api.nvim_buf_get_name(args.buf):match('copilot%-chat') then
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

        -- python venv activation
        local venv_path = vim.fn.getcwd() .. '/venv/bin/activate'
        if vim.fn.filereadable(venv_path) == 0 then
            venv_path = vim.fn.getcwd() .. '/.venv/bin/activate'
        end

        if vim.fn.filereadable(venv_path) == 1 then
            vim.api.nvim_chan_send(vim.bo[terminal_bufnr].channel, 'source ' .. venv_path .. '\n')
        end
    end
end

vim.keymap.set({ 'n', 'i', 't' }, '<C-\\>', toggle_terminal, { silent = true })
vim.keymap.set('t', '<c-x>', '<c-\\><c-n>')

-- my own plugin development
require('inline-edit').setup()

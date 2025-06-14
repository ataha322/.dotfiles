-- Bootstrap lazy.nvim -------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
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
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "number"
-- vim.opt.colorcolumn = "120"

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.compatible = false

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.clipboard = {'unnamedplus', 'unnamedplus'}
vim.opt.swapfile = false

vim.g.netrw_banner = false
vim.g.netrw_liststyle = 3

-- vim.opt.termguicolors = true

vim.g.have_nerd_font = true

vim.opt.incsearch = true
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.breakindent = true
vim.opt.mouse = ''
vim.opt.undofile = false
vim.opt.cursorline = true

vim.opt.completeopt:append({'noselect', 'fuzzy', 'popup'})
-----------------------------------------------------------------------

-- SECTION - COLORSCHEME ----------------------------------------------
vim.cmd.colorscheme("default")
vim.api.nvim_set_hl(0, "Normal", { bg = "none"})
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none"})
-- vim.api.nvim_set_hl(0, "PMenu", { bg = "none"})

-- torte
-- koehler
-- rose-pine
-- elflord
-- murphy
-- quiet
-- retrobox
-- vim
-- default
-----------------------------------------------------------------------


-- SECTION - KEY MAPPINGS -----------------------------------------
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
-- vim.keymap.set("n", "<C-n>", vim.cmd.bn)
-- vim.keymap.set("n", "<C-p>", vim.cmd.bp)
vim.keymap.set("n", "<leader>q", vim.cmd.bd)

-- move lines up and down
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")

-- highlight all occurrences of the word under cursor
vim.keymap.set("n", "<leader>h", function()
    local word = vim.fn.expand("<cword>")
    vim.cmd("let @/='" .. word .. "'")
    vim.cmd("set hlsearch")
end)
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
    vim.cmd("w ! python3")
end)

-- run python on selected lines
vim.keymap.set("v", "<leader>py", function()
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")
    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end
    vim.api.nvim_out_write('\n') -- clear command line
    vim.cmd(start_line .. "," .. end_line .. "w ! python3")
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

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking',
    callback = function()
        vim.highlight.on_yank({ timeout = 300 })
    end,
})

-- Save and restore window view when switching buffers
vim.api.nvim_create_autocmd({'BufLeave', 'BufWinLeave'}, {
    callback = function(args)
        if vim.bo[args.buf].buftype == '' then  -- Only for normal buffers
            vim.b[args.buf].view = vim.fn.winsaveview()
        end
    end
})

vim.api.nvim_create_autocmd({'BufEnter', 'BufWinEnter'}, {
    callback = function(args)
        if vim.b[args.buf].view ~= nil then
            vim.fn.winrestview(vim.b[args.buf].view)
        end
    end
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
---------------------------------------------------------------------------------------


-- SECTION - Setup lazy.nvim -------------------------------------------------
require("lazy").setup({
    spec = {
        {
            "nvim-treesitter/nvim-treesitter",
            branch = 'master',
            lazy = false,
            build = ":TSUpdate"
        },
        {
            'nvim-telescope/telescope.nvim',
            tag = '0.1.8',
            dependencies = { 'nvim-lua/plenary.nvim' },
            lazy = false,
        },
        {'mason-org/mason.nvim', opts = {}, lazy = false},
        {'nvim-telescope/telescope-ui-select.nvim', event="VeryLazy"},
        {'tpope/vim-surround', event = "VeryLazy"},
        {'tpope/vim-commentary', event = "VeryLazy"},
        {'tpope/vim-fugitive', event = "VeryLazy"},

        {
            "CopilotC-Nvim/CopilotChat.nvim",
            event = "VeryLazy",
            dependencies = {
                { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
                { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
            },
            build = "make tiktoken", -- Only on MacOS or Linux
            -- opts = {
            --     -- See Configuration section for options
            -- },
            -- See Commands section for default commands if you want to lazy load on them
        },
    },
    install = {},
    checker = { enabled = false },
})
-----------------------------------------------------------------------------


-- SECTION - Treesitter -----------------------------------------------------------
require 'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all" (the five listed parsers should always be installed)
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "go", "python", "cpp",
        "markdown", "markdown_inline", "diff", "jsonc", "json", "yaml", "toml"},

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = false,

    highlight = {
        enable = true,

        -- Disable slow treesitter highlight for large files
        disable = function(lang, buf)
            local max_filesize = 500 * 1024
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },

    indent = {
        enable = true
    },
}
-----------------------------------------------------------------------------------


-- SECTION - Telescope ------------------------------------------------------------
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
        },
        border = true,
        layout_strategy = 'vertical',
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
            "node_modules",
        },
    },
    pickers = {

    },
    extensions = {
        ["ui-select"] = {
            themes.get_dropdown { }
        }
    }
})
telescope.load_extension("ui-select")

function GetVisualSelection()
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
    builtin.grep_string({ search = GetVisualSelection() })
end)

vim.keymap.set('n', 'grr', builtin.lsp_references)
vim.keymap.set('n', 'gri', builtin.lsp_implementations)
vim.keymap.set('n', 'grd', builtin.lsp_definitions)
vim.keymap.set('n', 'grt', builtin.lsp_type_definitions)
vim.keymap.set('n', 'grc', builtin.lsp_incoming_calls)
vim.keymap.set('n', 'grC', builtin.lsp_outgoing_calls)
-----------------------------------------------------------------------------


-- SECTION - LSP ---------------------------------------------------------------
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end,
})

vim.diagnostic.config({
    -- virtual_lines = { current_line = true },
    virtual_text = { current_line = true },
})

-- Servers:

vim.lsp.config.clangd = {
    cmd = {'clangd', '--clang-tidy', '--background-index'},
    root_markers = {'compile_commands.json', 'compile_flags.txt'},
    filetypes = {'c', 'cpp'},
}

vim.lsp.config.luals = {
    cmd = {'lua-language-server'},
    root_markers = {'.luarc.json', '.luarc.jsonc'},
    filetypes = {'lua'},
}

vim.lsp.config.gopls = {
    cmd = {'gopls'},
    root_markers = {'go.mod', 'go.sum'},
    filetypes = {'go', 'gomod', 'gowork', 'gotmpl', 'gosum'},
}

vim.lsp.config.tsserver = {
    cmd = {'typescript-language-server', '--stdio'},
    root_markers = {'package.json', 'tsconfig.json', 'jsconfig.json', 'package-lock.json'},
    filetypes = {'javascript', 'typescript', 'javascriptreact', 'typescriptreact'},
    settings = {
        configuration = {
            preferGoToSourceDefinition = true,
        },
    },
}

vim.lsp.config.eslint = {
    cmd = {'vscode-eslint-language-server', '--stdio'},
    root_markers = {'package.json', 'tsconfig.json', 'jsconfig.json', 'package-lock.json'},
    filetypes = {'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'javascript.jsx', 'typescript.jsx'},
    settings = {
        useESLintClass = true,
        nodePath = "",
        codeActionsOnSave = {
            enable = false,
            mode = "all",
        },
        experimental = {
            useFlatConfig = false,
        },
    }
}

vim.lsp.config.pyright = {
    cmd = { 'basedpyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = {
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        'pyrightconfig.json',
        '.git',
    },
    settings = {
        basedpyright = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = 'workspace',
                typeCheckingMode = "off",
                inlayHints = {
                    functionReturnTypes = false,
                    variableTypes = false,
                },
            },
        },
        python = {
            pythonPath = {"venv/bin/python", ".venv/bin/python", "/opt/homebrew/bin/python3", "/usr/bin/python3"},
            venvPath = {"venv", ".venv"},
        },
    },
}

vim.lsp.enable({'luals', 'clangd', 'gopls', 'tsserver', 'eslint', 'pyright'})

-- grn in Normal mode maps to vim.lsp.buf.rename()
-- gra in Normal and Visual mode maps to vim.lsp.buf.code_action()
-- CTRL-S in Insert and Select mode maps to vim.lsp.buf.signature_help()
-- gO in Normal mode maps to vim.lsp.buf.document_symbol()
vim.keymap.set("n", "grD", function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end)
vim.keymap.set("n", "grf", vim.lsp.buf.format)
vim.keymap.set("v", "grf", vim.lsp.buf.format)
-----------------------------------------------------------------------------------------


-- SECTION - AI Code Completion and Agents---------------------------------------
local chat = require("CopilotChat")
chat.setup {

    -- Shared config starts here (can be passed to functions at runtime and configured via setup function)

    system_prompt = 'COPILOT_INSTRUCTIONS', -- System prompt to use (can be specified manually in prompt via /).

    model = 'claude-3.5-sonnet', -- Default model to use, see ':CopilotChatModels' for available models (can be specified manually in prompt via $).
    agent = 'copilot', -- Default agent to use, see ':CopilotChatAgents' for available agents (can be specified manually in prompt via @).
    context = nil, -- Default context or array of contexts to use (can be specified manually in prompt via #).
    sticky = nil, -- Default sticky prompt or array of sticky prompts to use at start of every new chat.

    temperature = 0.1, -- GPT result temperature
    headless = false, -- Do not write to chat buffer and use history (useful for using custom processing)
    stream = nil, -- Function called when receiving stream updates (returned string is appended to the chat buffer)
    callback = nil, -- Function called when full response is received (retuned string is stored to history)
    remember_as_sticky = true, -- Remember model/agent/context as sticky prompts when asking questions

    -- default window options
    window = {
        layout = 'vertical', -- 'vertical', 'horizontal', 'float', 'replace', or a function that returns the layout
        width = 0.35, -- fractional width of parent, or absolute width in columns when > 1
        height = 0.5, -- fractional height of parent, or absolute height in rows when > 1
        -- Options below only apply to floating windows
        relative = 'editor', -- 'editor', 'win', 'cursor', 'mouse'
        border = 'single', -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
        row = nil, -- row position of the window, default is centered
        col = nil, -- column position of the window, default is centered
        title = 'Copilot Chat', -- title of chat window
        footer = nil, -- footer of chat window
        zindex = 1, -- determines if window is on top or below other floating windows
    },

    show_help = true, -- Shows help message as virtual lines when waiting for user input
    highlight_selection = true, -- Highlight selection
    highlight_headers = true, -- Highlight headers in chat, disable if using markdown renderers (like render-markdown.nvim)
    references_display = 'virtual', -- 'virtual', 'write', Display references in chat as virtual text or write to buffer
    auto_follow_cursor = false, -- Auto-follow cursor in chat
    auto_insert_mode = false, -- Automatically enter insert mode when opening window and on new prompt
    insert_at_end = false, -- Move cursor to end of buffer when inserting text
    clear_chat_on_new_prompt = false, -- Clears chat on every new prompt

    -- Static config starts here (can be configured only via setup function)

    debug = false, -- Enable debug logging (same as 'log_level = 'debug')
    log_level = 'info', -- Log level to use, 'trace', 'debug', 'info', 'warn', 'error', 'fatal'
    proxy = nil, -- [protocol://]host[:port] Use this proxy
    allow_insecure = false, -- Allow insecure server connections

    chat_autocomplete = true, -- Enable chat autocompletion (when disabled, requires manual `mappings.complete` trigger)

    log_path = vim.fn.stdpath('state') .. '/CopilotChat.log', -- Default path to log file
    history_path = vim.fn.stdpath('data') .. '/copilotchat_history', -- Default path to stored history

    question_header = '# User ', -- Header to use for user questions
    answer_header = '# Copilot ', -- Header to use for AI answers
    error_header = '# Error ', -- Header to use for errors
    separator = '───', -- Separator to use in chat

    -- default prompts
    -- see config/prompts.lua for implementation
    prompts = {
        Explain = {
            prompt = 'Write an explanation for the selected code as paragraphs of text.',
            system_prompt = 'COPILOT_EXPLAIN',
        },
        Review = {
            prompt = 'Review the selected code.',
            system_prompt = 'COPILOT_REVIEW',
        },
        Fix = {
            prompt = 'There is a problem in this code. Identify the issues and rewrite the code with fixes. Explain what was wrong and how your changes address the problems.',
        },
        Optimize = {
            prompt = 'Optimize the selected code to improve performance and readability. Explain your optimization strategy and the benefits of your changes.',
        },
        Docs = {
            prompt = 'Please add documentation comments to the selected code.',
        },
        Tests = {
            prompt = 'Please generate tests for my code.',
        },
        Commit = {
            prompt = 'Write commit message for the change with commitizen convention. Keep the title under 50 characters and wrap message at 72 characters. Format as a gitcommit code block.',
            context = 'git:staged',
        },
    },

    -- default mappings
    -- see config/mappings.lua for implementation
    mappings = {
        complete = {
            insert = '<Tab>',
        },
        close = {
            normal = 'q',
            insert = '<C-c>',
        },
        reset = {
            normal = '<C-l>',
            insert = '<C-l>',
        },
        submit_prompt = {
            normal = '<CR>',
            insert = '<C-s>',
        },
        toggle_sticky = {
            normal = 'grr',
        },
        clear_stickies = {
            normal = 'grx',
        },
        accept_diff = {
            normal = '<C-y>',
            insert = '<C-y>',
        },
        jump_to_diff = {
            normal = 'gj',
        },
        quickfix_answers = {
            normal = 'gqa',
        },
        quickfix_diffs = {
            normal = 'gqd',
        },
        yank_diff = {
            normal = 'gy',
            register = '"', -- Default register to use for yanking
        },
        show_diff = {
            normal = 'gd',
            full_diff = false, -- Show full diff instead of unified diff when showing diff window
        },
        show_info = {
            normal = 'gi',
        },
        show_context = {
            normal = 'gc',
        },
        show_help = {
            normal = 'gh',
        },
    },
}

vim.api.nvim_create_autocmd('BufEnter', {
    pattern = 'copilot-*',
    callback = function()
        -- Set buffer-local options
        vim.opt_local.relativenumber = false
        vim.opt_local.number = false
        vim.opt_local.conceallevel = 0
    end
})

vim.keymap.set({ 'n' }, '<leader>aa', chat.toggle, { desc = 'AI Toggle' })
vim.keymap.set({ 'v' }, '<leader>aa', chat.open, { desc = 'AI Open' })
vim.keymap.set({ 'n' }, '<leader>ax', chat.reset, { desc = 'AI Reset' })
vim.keymap.set({ 'n' }, '<leader>as', chat.stop, { desc = 'AI Stop' })
vim.keymap.set({ 'n' }, '<leader>am', chat.select_model, { desc = 'AI Models' })
vim.keymap.set({ 'n', 'v' }, '<leader>ap', chat.select_prompt, { desc = 'AI Prompts' })
vim.keymap.set({ 'n', 'v' }, '<leader>aq', function()
    vim.ui.input({
        prompt = 'AI Question> ',
    }, function(input)
        if input ~= '' then
            chat.ask(input)
        end
    end)
end, { desc = 'AI Question' })

-- Copilot.vim

vim.g.copilot_no_tab_map = true
vim.g.copilot_settings = { selectedCompletionModel = 'gpt-4o-copilot' }
vim.keymap.set('i', '<C-f>', 'copilot#Accept("")', {
    expr = true,
    replace_keycodes = false
})
vim.keymap.set('i', '<C-\\>', '<Plug>(copilot-suggest)')
-- vim.keymap.set('i', '<leader>we', '<Plug>(copilot-next)')
-- vim.keymap.set('i', '<leader>wq', '<Plug>(copilot-previous)')
-- vim.keymap.set('i', '<leader>wo', '<Plug>(copilot-accept-word)')
-- vim.keymap.set('i', '<leader>wl', '<Plug>(copilot-accept-line)')

-- <C-]>                   Dismiss the current suggestion.
-- <Plug>(copilot-dismiss)
-- <M-]>                   Cycle to the next suggestion, if one is available.
-- <Plug>(copilot-next)
-- <M-[>                   Cycle to the previous suggestion.
-- <Plug>(copilot-previous)
-- <M-\>                   Explicitly request a suggestion, even if Copilot
-- <Plug>(copilot-suggest) is disabled.
-- <M-Right>               Accept the next word of the current suggestion.
-- <Plug>(copilot-accept-word)
-- <M-C-Right>             Accept the next line of the current suggestion.
-- <Plug>(copilot-accept-line)

vim.g.copilot_filetypes = {
    ["*"] = false,
    javascript = true,
    typescript = true,
    javascriptreact = true,
    typescriptreact = true,
    go = true,
    python = true,
    lua = true,
}
-- disable Copilot on startup
vim.cmd('Copilot disable')

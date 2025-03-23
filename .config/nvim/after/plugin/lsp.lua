local lspconfig = require('lspconfig')
local cmp_nvim_lsp = require('cmp_nvim_lsp')
local builtin = require('telescope.builtin')
local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')

-- Add cmp_nvim_lsp capabilities settings to lspconfig
-- This should be executed before you configure any language server
local lspconfig_defaults = lspconfig.util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
    'force',
    lspconfig_defaults.capabilities,
    cmp_nvim_lsp.default_capabilities()
)

-- This is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd('LspAttach', { desc = 'LSP actions',
    callback = function(event)
        local opts = {buffer = event.buf}
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('v', '<F3>', function()
            vim.lsp.buf.format({ async = false, timeout_ms = 5000 })
        end, opts)
        vim.keymap.set('n', '<leader>fs', builtin.lsp_dynamic_workspace_symbols)
    end,
})

mason.setup({})
mason_lspconfig.setup({
    ensure_installed = { 'clangd', 'gopls', 'lua_ls' },
    handlers = {
        function(server_name)
            lspconfig[server_name].setup({
                autostart = false,
            })
        end,
        lua_ls = function()
            lspconfig.lua_ls.setup({
                settings = {
                    Lua = {
                        telemetry = {
                            enable = false
                        },
                    },
                },
                on_init = function(client)
                    local join = vim.fs.joinpath
                    local path = client.workspace_folders[1].name

                    -- Don't do anything if there is project local config
                    if vim.uv.fs_stat(join(path, '.luarc.json')) 
                        or vim.uv.fs_stat(join(path, '.luarc.jsonc'))
                    then
                        return
                    end

                    -- Apply neovim specific settings
                    local runtime_path = vim.split(package.path, ';')
                    table.insert(runtime_path, join('lua', '?.lua'))
                    table.insert(runtime_path, join('lua', '?', 'init.lua'))

                    local nvim_settings = {
                        runtime = {
                            -- Tell the language server which version of Lua you're using
                            version = 'LuaJIT',
                            path = runtime_path
                        },
                        diagnostics = {
                            -- Get the language server to recognize the `vim` global
                            globals = {'vim'}
                        },
                        workspace = {
                            checkThirdParty = false,
                            library = {
                                -- Make the server aware of Neovim runtime files
                                vim.env.VIMRUNTIME,
                                vim.fn.stdpath('config'),
                            },
                        },
                    }

                    client.config.settings.Lua = vim.tbl_deep_extend(
                        'force',
                        client.config.settings.Lua,
                        nvim_settings
                    )
                end,
            })
        end,
    },
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, { border = "rounded" }
)
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help, { border = "rounded" }
)

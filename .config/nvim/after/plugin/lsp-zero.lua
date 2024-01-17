local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp_zero.default_keymaps({ buffer = bufnr })
end)


require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {'gopls', 'lua_ls', 'texlab'},
    handlers = {
        lsp_zero.default_setup,
    },
})

local lua_opts = lsp_zero.nvim_lua_ls()
require('lspconfig').lua_ls.setup(lua_opts)

require('lspconfig').clangd.setup({})

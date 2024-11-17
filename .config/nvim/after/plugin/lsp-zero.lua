local lsp_zero = require('lsp-zero')
local lspconfig = require('lspconfig')

lsp_zero.on_attach(function(client, bufnr)
    lsp_zero.default_keymaps({ buffer = bufnr })
    local opts = { buffer = bufnr }

    vim.keymap.set({ 'n', 'x' }, 'gq', function()
	vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
    end, opts)
end)


require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = { 'clangd', 'gopls', 'lua_ls' },
    handlers = {
	function(server_name)
	    lspconfig[server_name].setup({})
	end,
    }
})

local lua_opts = lsp_zero.nvim_lua_ls()
lspconfig.lua_ls.setup(lua_opts)

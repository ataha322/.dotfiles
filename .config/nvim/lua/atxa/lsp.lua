require("mason").setup()

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end,
})

vim.diagnostic.config({
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
    filetypes = {'go'},
}

vim.lsp.enable({'luals', 'clangd', 'gopls'})

-- grn in Normal mode maps to vim.lsp.buf.rename()
-- grr in Normal mode maps to vim.lsp.buf.references()
-- gri in Normal mode maps to vim.lsp.buf.implementation()
-- gO in Normal mode maps to vim.lsp.buf.document_symbol()
-- gra in Normal and Visual mode maps to vim.lsp.buf.code_action()
-- CTRL-S in Insert and Select mode maps to vim.lsp.buf.signature_help()
vim.keymap.set("n", "grd", function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end)

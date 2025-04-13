vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end,
})

vim.diagnostic.config({
    virtual_text = { current_line = true }
})

-- Servers:

vim.lsp.config.clangd = {
    cmd = {'clangd', '--background-index'},
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

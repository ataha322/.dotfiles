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

vim.diagnostic.config({
    -- virtual_lines = { current_line = true },
    -- virtual_text = { current_line = true },
    jump = {
        on_jump = function(diagnostic, bufnr)
            vim.diagnostic.open_float()
        end,
    },
    update_in_insert = true,
})


vim.lsp.enable({ 'ts_ls', 'basedpyright', 'gopls', 'lua_ls', 'rust_analyzer' })

vim.lsp.codelens.enable(false)

vim.keymap.set('n', 'grk', vim.diagnostic.open_float)
vim.keymap.set("n", "grD", function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end)
vim.keymap.set('n', "grh", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end)
vim.keymap.set('n', "grl", function()
    vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled())
end)

vim.pack.add({
    { src = "https://github.com/stevearc/conform.nvim" },
})

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

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

vim.keymap.set({ 'n', 'v' }, "grf", function()
    require('conform').format()
end)

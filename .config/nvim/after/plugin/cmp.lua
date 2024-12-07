local cmp = require('cmp')

cmp.setup({
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    },

    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },

    mapping = cmp.mapping.preset.insert({
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),

        ['<C-n>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                -- cmp.complete()
                fallback()
            end
        end),
        ['<C-p>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                -- cmp.complete()
                fallback()
            end
        end),
    }),

    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
    }, {
            { name = 'buffer' },
        }),

    preselect = 'item',
    completion = {
        completeopt = 'menu,menuone,noinsert',
        -- autocomplete = false,
    },
})

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
    -- Preselect the first item in the completion menu
    preselect = 'item',
    completion = {
        completeopt = 'menu,menuone,noinsert',

        -- Turn off autocompletion
        autocomplete = false
    },

    mapping = cmp.mapping.preset.insert({
        -- `Enter` key to confirm completion
        ['<C-CR>'] = cmp.mapping.confirm({ select = false }),

        -- Navigate between snippet placeholder
        ['<C-f>'] = cmp_action.luasnip_jump_forward(),
        ['<C-b>'] = cmp_action.luasnip_jump_backward(),

        -- Scroll up and down in the completion documentation
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),

        -- Tab completion
        ['<Tab>'] = cmp_action.tab_complete(),
        ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
    })
})

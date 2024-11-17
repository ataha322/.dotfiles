local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()
local cmp_format = require('lsp-zero').cmp_format({ details = true })

cmp.setup({
    snippet = {
        expand = function(args)
            -- require('luasnip').lsp_expand(args.body)
	    vim.snippet.expand(args.body)
        end,
    },

    window = {
	-- completion = cmp.config.window.bordered(),
	-- documentation = cmp.config.window.bordered(),
    },

    mapping = cmp.mapping.preset.insert({
        -- ['<C-CR>'] = cmp.mapping.confirm({ select = true }),
	['<C-e>'] = function(fallback)
	    if cmp.visible() then
		cmp.mapping.confirm()
	    else
		fallback()
	    end
	end,

        -- ['<C-f>'] = cmp_action.luasnip_jump_forward(),
        -- ['<C-b>'] = cmp_action.luasnip_jump_backward(),

        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),

        ['<C-p>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                -- cmp.complete()
		fallback()
            end
        end),
        ['<C-n>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                -- cmp.complete()
		fallback()
            end
        end),
    }),

    sources = cmp.config.sources({
	{ name = 'nvim_lsp' },
	-- { name = 'luasnip' },
    }, {
	    { name = 'buffer' },
	}),

    preselect = 'item',
    completion = {
        completeopt = 'menu,menuone,noinsert',
        -- autocomplete = false,
    },

    --- (Optional) Show source name in completion menu
    formatting = cmp_format,
})

require('lualine').setup {
    options = {
        theme = 'gruvbox-material',
        component_separators = '|',
        section_separators = '',
    },
    sections = {
        lualine_a = {
            {
                'buffers',
            }
        },
    },
}

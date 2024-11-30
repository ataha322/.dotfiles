require("rose-pine").setup({
    variant = "main", -- auto, main, moon, or dawn
    dark_variant = "main", -- main, moon, or dawn
    dim_inactive_windows = false,
    extend_background_behind_borders = true,

    styles = {
        bold = true,
        italic = true,
        transparency = false,
    },
})

vim.cmd.colorscheme("rose-pine")

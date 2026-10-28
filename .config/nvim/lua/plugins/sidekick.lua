vim.pack.add({
    { src = "https://github.com/folke/sidekick.nvim" },
})

require("sidekick").setup({
    nes = {
        enabled = false,
    },
    cli = {
        win = {
            layout = "float", ---@type "float"|"left"|"bottom"|"top"|"right"
            --- Options used when layout is "float"
            ---@type vim.api.keyset.win_config
            float = {
                width = 0.8,
                height = 0.8,
                title = "",
            },
        },
        picker = "telescope",
    },
})

vim.keymap.set({ "n", "t", "i", "x" }, "<c-.>",
    function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end,
    { desc = "Sidekick Toggle" })
vim.keymap.set({ "x", "n" }, "<leader>at", function() require("sidekick.cli").send({ msg = "{this}" }) end,
    { desc = "Send This" })
vim.keymap.set("n", "<leader>af", function() require("sidekick.cli").send({ msg = "{file}" }) end, { desc = "Send File" })
vim.keymap.set("x", "<leader>av", function() require("sidekick.cli").send({ msg = "{selection}" }) end,
    { desc = "Send Visual Selection" })
vim.keymap.set({ "n", "x" }, "<leader>ap", function() require("sidekick.cli").prompt() end,
    { desc = "Sidekick Select Prompt" })

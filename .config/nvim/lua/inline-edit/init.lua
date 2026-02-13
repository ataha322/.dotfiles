local M = {}

local ui = require('inline-edit.ui')
local context = require('inline-edit.context')
local llm = require('inline-edit.llm')
local diff = require('inline-edit.diff')
local config = require('inline-edit.config')

---@return nil
function M.open_prompt()
    -- capture context
    local ctx = context.get()

    -- go to normal mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)

    vim.ui.input({ prompt = 'Edit instruction: ' }, function(input)
        if not input or input == "" then
            return
        end

        ui.show_processing(ctx)

        llm.call(input, ctx, function(llm_response)
            ui.clear_processing(ctx)

            local ok, difference = pcall(diff.get, ctx, llm_response)
            if not ok then
                vim.notify("inline-edit: " .. tostring(difference), vim.log.levels.ERROR)
                return
            end

            ui.show_results(ctx, difference)
        end, function(err)
            ui.clear_processing(ctx)
            vim.notify("inline-edit: " .. err, vim.log.levels.ERROR)
        end)
    end)
end

---@param opts InlineEditConfig|nil
function M.setup(opts)
    config.setup(opts)

    local keymaps = config.options.keymaps
    if keymaps.open_prompt then
        vim.keymap.set({ 'n', 'v' }, keymaps.open_prompt, M.open_prompt, {
            silent = true,
            desc = "Open inline-edit prompt",
        })
    end

    ui.setup()
end

return M

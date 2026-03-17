local M = {}

local ui = require('inline-edit.ui')
local context = require('inline-edit.context')
local llm = require('inline-edit.llm')
local config = require('inline-edit.config')
local logging = require('inline-edit.logging')

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
            ui.clear_processing(ctx.bufnr)

            logging.log("LLM response: " .. llm_response)
            ui.apply_response(ctx, llm_response)
        end, function(err)
            ui.clear_processing(ctx.bufnr)
            vim.notify("inline-edit: " .. err, vim.log.levels.ERROR)
        end)
    end)
end

local function setup_autocommands()
    local augroup = vim.api.nvim_create_augroup("InlineEdit", { clear = true })

    -- Clean up state when buffer is deleted
    vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
        group = augroup,
        callback = function(ev)
            ui.clear_processing(ev.buf)
        end,
    })
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

    setup_autocommands()
end

return M

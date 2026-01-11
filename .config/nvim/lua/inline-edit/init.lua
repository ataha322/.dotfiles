local M = {}

local ui = require('inline-edit.ui')
local context = require('inline-edit.context')
local llm = require('inline-edit.llm')
local diff = require('inline-edit.diff')

---@return nil
function M.open_prompt()
    vim.ui.input({ prompt = 'Enter edit prompt:' }, function(input)
        ui.processing_request(input)

        local ctx = context.get()

        local llm_response = llm.call(input, ctx)

        local difference = diff.get(ctx, llm_response)

        ui.show_results(ctx, difference)
    end)
end

return M

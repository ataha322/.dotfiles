local M = {}
local logging = require('inline-edit.logging')

---@class Context
---@field bufnr number
---@field start_line number
---@field end_line number
---@field original_lines string[]
---@field lines_before string[]
---@field lines_after string[]

---@return Context
function M.get()
    local bufnr = vim.api.nvim_get_current_buf()

    -- Get the visual selection range using marks (these are set when leaving visual mode)
    local start_line = vim.fn.getpos("v")[2]
    local end_line = vim.fn.getpos(".")[2]

    if end_line < start_line then
        start_line, end_line = end_line, start_line
    end

    local original_lines = vim.api.nvim_buf_get_lines(bufnr, start_line-1, end_line, false)
    local lines_before = vim.api.nvim_buf_get_lines(bufnr, start_line - 50, start_line-1, false)
    local lines_after = vim.api.nvim_buf_get_lines(bufnr, end_line, end_line + 20, false)

    logging.log("Getting context for lines " .. start_line .. " to " .. end_line)
    logging.log("Lines before: " .. vim.inspect(lines_before))
    logging.log("Original lines: " .. vim.inspect(original_lines))
    logging.log("Lines after: " .. vim.inspect(lines_after))

    return {
        bufnr = bufnr,
        start_line = start_line,
        end_line = end_line,
        original_lines = original_lines,
        lines_before = lines_before,
        lines_after = lines_after,
    }
end

return M

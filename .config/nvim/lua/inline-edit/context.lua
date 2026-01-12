local M = {}
local logging = require('inline-edit.logging')

---@class Context
---@field bufnr number
---@field start_line number 1-based
---@field end_line number 1-based, inclusive
---@field original_lines string[]
---@field lines_before string[]
---@field lines_after string[]

-- Number of context lines to include before/after selection
local CONTEXT_LINES = 50

---@return Context
function M.get()
    local bufnr = vim.api.nvim_get_current_buf()
    local mode = vim.fn.mode()

    local start_line, end_line

    if mode:match("[vV\22]") then
        -- Currently in visual mode
        start_line = vim.fn.getpos("v")[2]
        end_line = vim.fn.getpos(".")[2]
    else
        -- Not in visual mode, try using '< and '> marks (last visual selection)
        start_line = vim.fn.getpos("'<")[2]
        end_line = vim.fn.getpos("'>")[2]
    end

    -- Validate we got valid line numbers
    if start_line == 0 or end_line == 0 then
        error("No visual selection found. Please select text first.")
    end

    -- Ensure start <= end
    if end_line < start_line then
        start_line, end_line = end_line, start_line
    end

    -- Validate lines are within buffer bounds
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    if start_line > line_count then
        error("Selection start line " .. start_line .. " is beyond buffer end " .. line_count)
    end
    end_line = math.min(end_line, line_count)

    local original_lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

    if #original_lines == 0 then
        error("Empty selection")
    end

    local before_start = math.max(0, start_line - 1 - CONTEXT_LINES)
    local lines_before = vim.api.nvim_buf_get_lines(bufnr, before_start, start_line - 1, false)
    local lines_after = vim.api.nvim_buf_get_lines(bufnr, end_line, end_line + CONTEXT_LINES, false)

    logging.log(string.format("context.get: lines %d-%d, %d lines selected, %d before, %d after",
        start_line, end_line, #original_lines, #lines_before, #lines_after))

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

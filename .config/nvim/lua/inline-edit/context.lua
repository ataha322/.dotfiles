local M = {}
local logging = require('inline-edit.logging')

---@class Context
---@field bufnr number
---@field start_line number 1-based
---@field end_line number 1-based, inclusive
---@field original_lines string[]
---@field lines_before string[]
---@field lines_after string[]

---@return Context
local function get_surrounding_lines()
    local CONTEXT_LINES = 50
    local bufnr = vim.api.nvim_get_current_buf()
    local mode = vim.fn.mode()

    local start_line, end_line

    -- if matches visual, or visual line, or <C-v> block mode
    if mode:match("[vV\22]") then
        start_line = vim.fn.getpos("v")[2]
        end_line = vim.fn.getpos(".")[2]
    else
        -- Not in visual mode, use current line only
        local current_line = vim.fn.line(".")
        start_line = current_line
        end_line = current_line
    end

    -- Validate we got valid line numbers
    if start_line == 0 or end_line == 0 then
        error("No visual selection found. Please select text first.")
    end

    -- Ensure start <= end
    if end_line < start_line then
        start_line, end_line = end_line, start_line
    end

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

---@return Context
function M.get()
    return get_surrounding_lines()
    -- return get_treesitter_context()
    -- return get_treesitter_and_lsp_context()
end

return M

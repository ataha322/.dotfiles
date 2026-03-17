local M = {}
local logging = require("inline-edit.logging")
local shimmer = require("inline-edit.shimmer")

---@param ctx Context
function M.show_processing(ctx)
    shimmer.start(ctx)
end

---@param bufnr number
function M.clear_processing(bufnr)
    shimmer.stop(bufnr)
end

---@param response string
---@return string[]
local function extract_code_lines(response)
    local code = response:match("<code>(.-)</code>")
    if not code then
        error("LLM response missing <code></code> tags:\n" .. response)
    end

    local cleaned = code:gsub("^\n", ""):gsub("\n$", "")
    return vim.split(cleaned, "\n", { plain = true })
end

---@param ctx Context
---@param response string
function M.apply_response(ctx, response)
    local ok, new_lines = pcall(extract_code_lines, response)
    if not ok then
        vim.notify("inline-edit: " .. tostring(new_lines), vim.log.levels.ERROR)
        return
    end

    logging.log(string.format(
        "applying response to buffer %d: lines %d-%d (%d -> %d lines)",
        ctx.bufnr,
        ctx.start_line,
        ctx.end_line,
        #ctx.original_lines,
        #new_lines
    ))

    vim.api.nvim_buf_set_lines(ctx.bufnr, ctx.start_line - 1, ctx.end_line, false, new_lines)
end

return M

local M = {}

---@class Hunk
---@field start_a integer Start line in original (1-based)
---@field count_a integer Number of lines in original
---@field start_b integer Start line in new (1-based)
---@field count_b integer Number of lines in new

---@class DiffResult
---@field original_lines string[]
---@field new_lines string[]
---@field hunks Hunk[]

--- Extract code from <code> tags in LLM response
---@param response string
---@return string
local function extract_code(response)
    local code = response:match("<code>(.-)</code>")
    if not code then
        error("LLM response missing <code></code> tags:\n" .. response)
    end
    -- Only trim the single newline right after <code> and before </code>
    return code:gsub("^\n", ""):gsub("\n$", "")
end

---@param original_lines string[]
---@param current_lines string[]
---@return Hunk[]
function M.compute(original_lines, current_lines)
    local original_text = table.concat(original_lines, "\n") .. "\n"
    local current_text = table.concat(current_lines, "\n") .. "\n"

    local indices = vim.diff(original_text, current_text, {
        result_type = "indices",
        algorithm = "patience",
    })

    local hunks = {}
    for _, hunk in ipairs(indices or {}) do
        table.insert(hunks, {
            start_a = hunk[1],
            count_a = hunk[2],
            start_b = hunk[3],
            count_b = hunk[4],
        })
    end

    return hunks
end

---@param ctx Context
---@param llm_response string
---@return DiffResult
function M.get(ctx, llm_response)
    local cleaned = extract_code(llm_response)
    local new_lines = vim.split(cleaned, "\n")
    local hunks = M.compute(ctx.original_lines, new_lines)

    return {
        original_lines = ctx.original_lines,
        new_lines = new_lines,
        hunks = hunks,
    }
end

return M

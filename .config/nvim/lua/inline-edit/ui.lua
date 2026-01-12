local M = {}
local diff = require("inline-edit.diff")
local logging = require("inline-edit.logging")
local config = require("inline-edit.config")

local ns_id = vim.api.nvim_create_namespace("inline-edit")
local ns_processing = vim.api.nvim_create_namespace("inline-edit-processing")

---@class Change
---@field bufnr number
---@field buf_start_line number 1-based line in buffer where this change starts
---@field original_lines string[] lines to be replaced (may be empty for insertions)
---@field new_lines string[] replacement lines (may be empty for deletions)

-- Active changes per buffer: bufnr -> Change[]
local active_changes = {}

---@param ctx Context
function M.show_processing(ctx)
    for i = ctx.start_line, ctx.end_line do
        vim.api.nvim_buf_set_extmark(ctx.bufnr, ns_processing, i - 1, 0, {
            line_hl_group = "CurSearch",
            priority = 100,
        })
    end
end

---@param ctx Context
function M.clear_processing(ctx)
    vim.api.nvim_buf_clear_namespace(ctx.bufnr, ns_processing, 0, -1)
end

---@param bufnr number
local function render(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

    local changes = active_changes[bufnr]
    if not changes or #changes == 0 then
        return
    end

    for _, change in ipairs(changes) do
        -- Highlight lines that will be deleted
        if #change.original_lines > 0 then
            for i = 0, #change.original_lines - 1 do
                local line_nr = change.buf_start_line - 1 + i
                vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_nr, 0, {
                    line_hl_group = "DiffDelete",
                })
            end
        end

        -- Show new lines as virtual text
        if #change.new_lines > 0 then
            local virt_lines = {}
            for _, line in ipairs(change.new_lines) do
                table.insert(virt_lines, { { line, "DiffAdd" } })
            end

            if #change.original_lines == 0 then
                -- Pure insertion: show above the current line
                vim.api.nvim_buf_set_extmark(bufnr, ns_id, change.buf_start_line - 1, 0, {
                    virt_lines = virt_lines,
                    virt_lines_above = true,
                })
            else
                -- Replacement: show after the last deleted line
                local last_deleted_line = change.buf_start_line - 1 + #change.original_lines - 1
                vim.api.nvim_buf_set_extmark(bufnr, ns_id, last_deleted_line, 0, {
                    virt_lines = virt_lines,
                    virt_lines_above = false,
                })
            end
        end
    end
end

---@param bufnr number
---@return Change|nil, number|nil
local function get_change_at_cursor(bufnr)
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1] -- 1-based
    local changes = active_changes[bufnr]
    if not changes then return nil, nil end

    for i, change in ipairs(changes) do
        local start_line = change.buf_start_line
        local end_line = change.buf_start_line + math.max(#change.original_lines, 1) - 1
        if cursor_line >= start_line and cursor_line <= end_line then
            return change, i
        end
    end
    return nil, nil
end

---@param bufnr number
---@param change_idx number
local function remove_change(bufnr, change_idx)
    local changes = active_changes[bufnr]
    if changes then
        table.remove(changes, change_idx)
        if #changes == 0 then
            active_changes[bufnr] = nil
        end
    end
    render(bufnr)
end

---@param bufnr number
local function accept_current(bufnr)
    local change, idx = get_change_at_cursor(bufnr)
    if not change then
        print("No inline-edit change at cursor")
        return
    end

    logging.log(string.format("accepting change %d at line %d", idx, change.buf_start_line))

    -- Replace original lines with new lines
    local start_idx = change.buf_start_line - 1
    local end_idx = start_idx + #change.original_lines
    vim.api.nvim_buf_set_lines(bufnr, start_idx, end_idx, false, change.new_lines)

    -- Adjust other changes that come after this one
    local line_delta = #change.new_lines - #change.original_lines
    local changes = active_changes[bufnr]
    for _, c in ipairs(changes) do
        if c.buf_start_line > change.buf_start_line then
            c.buf_start_line = c.buf_start_line + line_delta
        end
    end

    remove_change(bufnr, idx)
    print("Accepted change")
end

---@param bufnr number
local function reject_current(bufnr)
    local change, idx = get_change_at_cursor(bufnr)
    if not change then
        print("No inline-edit change at cursor")
        return
    end

    logging.log(string.format("rejecting change %d at line %d", idx, change.buf_start_line))
    remove_change(bufnr, idx)
    print("Rejected change")
end

---@param bufnr number
local function accept_all(bufnr)
    local changes = active_changes[bufnr]
    if not changes or #changes == 0 then
        print("No inline-edit changes")
        return
    end

    logging.log(string.format("accepting all %d changes", #changes))

    -- Accept in reverse order to preserve line numbers
    for i = #changes, 1, -1 do
        local change = changes[i]
        local start_idx = change.buf_start_line - 1
        local end_idx = start_idx + #change.original_lines
        vim.api.nvim_buf_set_lines(bufnr, start_idx, end_idx, false, change.new_lines)
    end

    active_changes[bufnr] = nil
    render(bufnr)
    print("Accepted all changes")
end

---@param bufnr number
local function reject_all(bufnr)
    local changes = active_changes[bufnr]
    if not changes or #changes == 0 then
        print("No inline-edit changes")
        return
    end

    logging.log(string.format("rejecting all %d changes", #changes))
    active_changes[bufnr] = nil
    render(bufnr)
    print("Rejected all changes")
end

local function setup_keymaps()
    local keymaps = config.options.keymaps

    if keymaps.accept then
        vim.keymap.set("n", keymaps.accept, function()
            accept_current(vim.api.nvim_get_current_buf())
        end, { silent = true, desc = "Accept inline-edit change" })
    end

    if keymaps.reject then
        vim.keymap.set("n", keymaps.reject, function()
            reject_current(vim.api.nvim_get_current_buf())
        end, { silent = true, desc = "Reject inline-edit change" })
    end

    if keymaps.accept_all then
        vim.keymap.set("n", keymaps.accept_all, function()
            accept_all(vim.api.nvim_get_current_buf())
        end, { silent = true, desc = "Accept all inline-edit changes" })
    end

    if keymaps.reject_all then
        vim.keymap.set("n", keymaps.reject_all, function()
            reject_all(vim.api.nvim_get_current_buf())
        end, { silent = true, desc = "Reject all inline-edit changes" })
    end
end

local function setup_autocommands()
    local augroup = vim.api.nvim_create_augroup("InlineEdit", { clear = true })

    -- Clean up state when buffer is deleted
    vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
        group = augroup,
        callback = function(ev)
            active_changes[ev.buf] = nil
        end,
    })
end

function M.setup()
    setup_keymaps()
    setup_autocommands()
end

---@param ctx Context
---@param diff_result DiffResult
function M.show_results(ctx, diff_result)
    local bufnr = ctx.bufnr

    if not active_changes[bufnr] then
        active_changes[bufnr] = {}
    end

    local hunks = diff.compute(ctx.original_lines, diff_result.new_lines)
    logging.log(string.format("show_results: %d hunks for buffer %d", #hunks, bufnr))

    if #hunks == 0 then
        print("No changes detected")
        return
    end

    for _, hunk in ipairs(hunks) do
        local original_hunk_lines = {}
        for i = hunk.start_a, hunk.start_a + hunk.count_a - 1 do
            table.insert(original_hunk_lines, ctx.original_lines[i])
        end

        local new_hunk_lines = {}
        for i = hunk.start_b, hunk.start_b + hunk.count_b - 1 do
            table.insert(new_hunk_lines, diff_result.new_lines[i])
        end

        local change = {
            bufnr = bufnr,
            buf_start_line = ctx.start_line + hunk.start_a - 1,
            original_lines = original_hunk_lines,
            new_lines = new_hunk_lines,
        }

        logging.log(string.format("  change at line %d: %d -> %d lines",
            change.buf_start_line, #original_hunk_lines, #new_hunk_lines))

        table.insert(active_changes[bufnr], change)
    end

    render(bufnr)
end

function M.clear()
    local bufnr = vim.api.nvim_get_current_buf()
    active_changes[bufnr] = nil
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
end

--- Check if buffer has pending changes
---@param bufnr number|nil
---@return boolean
function M.has_changes(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local changes = active_changes[bufnr]
    return changes ~= nil and #changes > 0
end

return M

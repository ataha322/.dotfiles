-- Inline edit: select lines, describe a change in a prompt that opens right next
-- to the selection, and the LLM's answer replaces the selected lines.
--
-- Prompt (a 1-line float that grows with its content, sitting in space reserved by virt_lines):
--   <CR> (normal mode)   submit
--   <Esc><Esc>           cancel a running request (prompt stays open for editing/resubmitting)
--   :q / <C-w>c / ...    close the prompt (cancels a running request)

local ai = require("ai")

local M = {}

---@class InlineEditConfig
---@field api_key? string|fun(): string
---@field base_url? string OpenAI-compatible endpoint (e.g. "https://api.openai.com/v1", "https://api.anthropic.com/v1/")
---@field request? table Merged into the chat completion request body. Replaced wholesale, not deep-merged.
---@field context_before? integer
---@field context_after? integer
---@field log_level? integer vim.log.levels.*; messages below it are dropped

---@type InlineEditConfig
local defaults = {
    api_key = nil,
    base_url = "https://api.z.ai/api/paas/v4",
    request = {
        model = "glm-5.3-flash",
        temperature = 0.2,
        reasoning_effort = "low",
    },
    context_before = 500,
    context_after = 100,
    log_level = vim.log.levels.INFO,
}

---@type InlineEditConfig
local options = vim.deepcopy(defaults)

local ns = vim.api.nvim_create_namespace("inline_edit")
local augroup = vim.api.nvim_create_augroup("InlineEdit", { clear = true })
local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local max_prompt_height = 10

local system_prompt = [[You are a code editing assistant embedded in a text editor.
You receive a file excerpt in <file>...</file>. The part to edit is marked with <selection>...</selection>.
Follow the user's instruction (in <instruction>...</instruction>) and output the code that replaces the selection.
The selection may be empty-ish or contain a placeholder; in that case write new code for that spot.
Keep the surrounding indentation style. Do not repeat code from outside the selection.
Respond with exactly one <code>...</code> block containing only the replacement code.]]

---@param level integer
---@param msg string
local function log(level, msg)
    if level >= options.log_level then
        vim.notify("inline-edit: " .. msg, level)
    end
end

-- All highlight groups, with the group each links to by default. Override them with nvim_set_hl().
local highlights = {
    InlineEditSelection = "Visual", -- selected lines while the prompt is open
    InlineEditPending = "DiffChange", -- selected lines while waiting for the response
    InlineEditPromptBusy = "Comment", -- prompt text while waiting (input is locked)
    InlineEditPromptError = "DiagnosticError", -- prompt text after a failed request
}

---@type table<string, { region: string, prompt?: string }>
local state_highlights = {
    idle = { region = "InlineEditSelection" },
    busy = { region = "InlineEditPending", prompt = "InlineEditPromptBusy" },
    failed = { region = "InlineEditSelection", prompt = "InlineEditPromptError" },
}

local function set_highlights()
    for group, link in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, { link = link, default = true })
    end
end

---@class InlineEditSession
---@field src_buf integer
---@field src_win integer
---@field region integer extmark spanning the selected lines; follows edits made while waiting
---@field anchor_row integer 0-based row carrying the virt_lines placeholder
---@field virt_above boolean
---@field prompt_buf integer
---@field prompt_win integer
---@field placeholder? integer extmark with the virt_lines the prompt sits in
---@field prompt_mark? integer extmark highlighting the prompt text
---@field spinner? integer extmark with the spinner
---@field state "idle"|"busy"|"failed"
---@field closed? boolean
---@field job? integer
---@field timer? uv.uv_timer_t

---@type InlineEditSession?
local session = nil

---@param s InlineEditSession
---@return integer start_row, integer end_row 0-based, end exclusive
local function region_rows(s)
    local mark = vim.api.nvim_buf_get_extmark_by_id(s.src_buf, ns, s.region, { details = true })
    return mark[1], math.max(mark[1], mark[3].end_row)
end

---@param s InlineEditSession
---@return string
local function build_user_message(s, instruction)
    local start_row, end_row = region_rows(s)
    local function text(from, to)
        return table.concat(vim.api.nvim_buf_get_lines(s.src_buf, from, to, false), "\n")
    end
    return string.format(
        "Filename: %s\nLanguage: %s\n<file>\n%s\n<selection>\n%s\n</selection>\n%s\n</file>\n<instruction>\n%s\n</instruction>",
        vim.fn.fnamemodify(vim.api.nvim_buf_get_name(s.src_buf), ":."),
        vim.bo[s.src_buf].filetype,
        text(math.max(0, start_row - options.context_before), start_row),
        text(start_row, end_row),
        text(end_row, end_row + options.context_after),
        instruction
    )
end

---@param response string
---@return string[]?
local function extract_code(response)
    local code = response:match("<code>(.-)</code>")
    if not code then
        return nil
    end
    code = code:gsub("^\n", ""):gsub("\n$", "")
    code = code:match("^```[^\n]*\n(.-)\n?```$") or code
    return vim.split(code, "\n", { plain = true })
end

---Resize the prompt to its content and reserve the same number of screen lines in the source window.
---@param s InlineEditSession
local function layout(s)
    if not vim.api.nvim_win_is_valid(s.prompt_win) or not vim.api.nvim_win_is_valid(s.src_win) then
        return
    end
    local height = math.min(max_prompt_height, vim.api.nvim_win_text_height(s.prompt_win, {}).all)
    local virt_lines = {}
    for i = 1, height do
        virt_lines[i] = { { "" } }
    end
    s.placeholder = vim.api.nvim_buf_set_extmark(s.src_buf, ns, s.anchor_row, 0, {
        id = s.placeholder,
        virt_lines = virt_lines,
        virt_lines_above = s.virt_above,
    })
    local textoff = vim.fn.getwininfo(s.src_win)[1].textoff
    vim.api.nvim_win_set_config(s.prompt_win, {
        relative = "win",
        win = s.src_win,
        bufpos = { s.anchor_row, 0 },
        row = s.virt_above and -height or 1,
        col = 0,
        width = math.max(1, vim.api.nvim_win_get_width(s.src_win) - textoff),
        height = height,
    })
    if height < max_prompt_height then
        -- it all fits now, but the view may still be scrolled from when the float was smaller
        vim.api.nvim_win_call(s.prompt_win, function() vim.fn.winrestview({ topline = 1 }) end)
    end
end

---Scroll the source window so the prompt's gap is on screen.
---@param s InlineEditSession
local function scroll_into_view(s)
    vim.api.nvim_win_call(s.src_win, function()
        local top = vim.fn.line("w0") - 1
        if s.virt_above and top == s.anchor_row then
            -- virt_lines above the top line are only visible through topfill
            vim.fn.winrestview({ topline = top + 1, topfill = vim.api.nvim_win_get_height(s.prompt_win) })
            return
        end
        local needed = vim.api.nvim_win_text_height(0, { start_row = top, end_row = s.anchor_row }).all
        if not s.virt_above then
            needed = needed + vim.api.nvim_win_get_height(s.prompt_win) -- not counted below the last buffer line
        end
        local overflow = needed - vim.api.nvim_win_get_height(0)
        if overflow > 0 then
            vim.cmd("normal! " .. overflow .. vim.keycode("<C-e>"))
        end
    end)
end

---Highlight the selected lines and the prompt according to the session state.
---@param s InlineEditSession
local function highlight(s)
    local groups = state_highlights[s.state]
    local start_row, end_row = region_rows(s)
    -- above LSP semantic tokens and other user highlights; the groups only set colors the syntax doesn't
    local priority = vim.hl.priorities.user + 1
    vim.api.nvim_buf_set_extmark(s.src_buf, ns, start_row, 0, {
        id = s.region,
        end_row = end_row,
        strict = false,
        right_gravity = false,
        hl_group = groups.region,
        hl_eol = true,
        priority = priority,
    })
    if groups.prompt then
        s.prompt_mark = vim.api.nvim_buf_set_extmark(s.prompt_buf, ns, 0, 0, {
            id = s.prompt_mark,
            end_row = vim.api.nvim_buf_line_count(s.prompt_buf),
            strict = false,
            hl_group = groups.prompt,
            hl_eol = true,
            priority = priority,
        })
    elseif s.prompt_mark then
        vim.api.nvim_buf_del_extmark(s.prompt_buf, ns, s.prompt_mark)
        s.prompt_mark = nil
    end
end

local cancel

---@param s InlineEditSession
---@param state "idle"|"busy"|"failed"
local function set_state(s, state)
    s.state = state
    if not vim.api.nvim_buf_is_valid(s.prompt_buf) then
        return
    end
    local busy = state == "busy"
    vim.bo[s.prompt_buf].modifiable = not busy
    if busy then
        vim.keymap.set("n", "<Esc><Esc>", function() cancel(s) end, { buffer = s.prompt_buf, desc = "Cancel inline edit" })
    else
        pcall(vim.keymap.del, "n", "<Esc><Esc>", { buffer = s.prompt_buf })
    end
    highlight(s)
end

---Stop the request and the spinner, if running. Safe to call any number of times.
---@param s InlineEditSession
local function stop(s)
    if s.job then
        local job = s.job
        s.job = nil -- on_exit sees this and ignores the result
        vim.fn.jobstop(job)
    end
    if s.timer then
        s.timer:stop()
        s.timer:close()
        s.timer = nil
    end
    if s.spinner and vim.api.nvim_buf_is_valid(s.prompt_buf) then
        vim.api.nvim_buf_del_extmark(s.prompt_buf, ns, s.spinner)
    end
    s.spinner = nil
end

---@param s InlineEditSession
local function close(s)
    if s.closed then
        return
    end
    s.closed = true
    stop(s)
    if session == s then
        session = nil
    end
    pcall(vim.api.nvim_del_augroup_by_name, "InlineEditPrompt")
    if vim.api.nvim_buf_is_valid(s.src_buf) then
        vim.api.nvim_buf_clear_namespace(s.src_buf, ns, 0, -1)
    end
    if vim.api.nvim_win_is_valid(s.prompt_win) then
        vim.api.nvim_win_close(s.prompt_win, true)
    end
    if vim.api.nvim_win_is_valid(s.src_win) then
        vim.api.nvim_set_current_win(s.src_win)
    end
end

---@param s InlineEditSession
---@param err string
local function fail(s, err)
    stop(s)
    set_state(s, "failed")
    log(vim.log.levels.ERROR, err)
end

---@param s InlineEditSession
function cancel(s)
    if s.state ~= "busy" then
        return
    end
    stop(s)
    set_state(s, "idle")
    log(vim.log.levels.INFO, "request cancelled")
end

---@param s InlineEditSession
---@param content string
local function apply(s, content)
    local lines = extract_code(content)
    if not lines then
        return fail(s, "response has no <code></code> block:\n" .. content)
    end
    local start_row, end_row = region_rows(s)
    local ok, err = pcall(vim.api.nvim_buf_set_lines, s.src_buf, start_row, end_row, false, lines)
    if not ok then
        return fail(s, "failed to apply edit: " .. err)
    end
    log(vim.log.levels.DEBUG, string.format("replaced lines %d-%d with %d lines", start_row + 1, end_row, #lines))
    close(s)
end

---@param s InlineEditSession
local function submit(s)
    if s.state == "busy" then
        return
    end
    local instruction = vim.trim(table.concat(vim.api.nvim_buf_get_lines(s.prompt_buf, 0, -1, false), "\n"))
    if instruction == "" then
        return
    end

    local api_key = options.api_key
    if type(api_key) == "function" then
        api_key = api_key()
    end
    if not api_key or api_key == "" then
        return fail(s, "api_key is not set, see require('ata-ai-coding').setup()")
    end

    local request = vim.tbl_extend("force", options.request, {
        stream = false,
        messages = {
            { role = "system", content = system_prompt },
            { role = "user", content = build_user_message(s, instruction) },
        },
    })
    log(vim.log.levels.TRACE, "request:\n" .. vim.inspect(request))

    local stdout, stderr = {}, {}
    local job
    local function on_exit(_, code)
        if s.job ~= job then
            return -- cancelled or superseded
        end
        s.job = nil
        local body = table.concat(stdout)
        log(vim.log.levels.TRACE, "response:\n" .. body)
        local ok, decoded = pcall(vim.json.decode, body, { luanil = { object = true, array = true } })
        local content = ok and type(decoded) == "table" and vim.tbl_get(decoded, "choices", 1, "message", "content")
        if code ~= 0 or not content then
            local detail = vim.trim(table.concat(stderr, "\n") .. body)
            return fail(s, string.format("request failed (curl exit code %d)%s", code, detail ~= "" and ": " .. detail or ""))
        end
        stop(s)
        apply(s, content)
    end

    -- ai.nvim only invokes on_chat_completion for responses that contain choices, so error responses would vanish
    -- silently. We collect stdout ourselves and decide in on_exit, which always runs.
    local client = ai.Client:new(options.base_url, api_key)
    job = client:chat_completion_create(request, function() end, nil, function(_, data)
        vim.list_extend(stdout, data)
    end, function(_, data)
        vim.list_extend(stderr, data)
    end, on_exit)
    if job <= 0 then
        return fail(s, "failed to start curl")
    end
    s.job = job

    set_state(s, "busy")
    local frame = 0
    s.timer = vim.uv.new_timer()
    s.timer:start(0, 100, vim.schedule_wrap(function()
        if not s.timer or not vim.api.nvim_buf_is_valid(s.prompt_buf) then
            return
        end
        frame = frame % #spinner_frames + 1
        -- "eol" already leaves one cell after the text, so two more spaces put it 3 cells away
        s.spinner = vim.api.nvim_buf_set_extmark(s.prompt_buf, ns, vim.api.nvim_buf_line_count(s.prompt_buf) - 1, 0, {
            id = s.spinner,
            virt_text = { { "  " .. spinner_frames[frame] .. " thinking", "InlineEditPromptBusy" } },
            virt_text_pos = "eol",
        })
    end))
end

---Open the prompt for the current visual selection. Must be called from visual mode.
function M.prompt()
    if not vim.fn.mode():match("^[vV\22]") then
        return log(vim.log.levels.WARN, "start from a visual selection")
    end
    if vim.bo.filetype == "inline_edit_prompt" then
        return
    end
    if session then
        if session.state == "busy" then
            return log(vim.log.levels.WARN, "a request is already running")
        end
        close(session)
    end

    local cursor_row = vim.fn.line(".") - 1
    local other_row = vim.fn.line("v") - 1
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)

    local src_buf = vim.api.nvim_get_current_buf()
    local src_win = vim.api.nvim_get_current_win()
    local start_row, end_row = math.min(cursor_row, other_row), math.max(cursor_row, other_row) + 1
    local below = cursor_row >= other_row
    local line_count = vim.api.nvim_buf_line_count(src_buf)

    -- The float sits in a gap made by virt_lines. Prefer "above the next line" over "below the last selected line",
    -- because a wrapped line would push the gap further down than row=1 from its start.
    local anchor_row, virt_above
    if not below then
        anchor_row, virt_above = start_row, true
    elseif end_row < line_count then
        anchor_row, virt_above = end_row, true
    else
        anchor_row, virt_above = end_row - 1, false
    end

    local prompt_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[prompt_buf].bufhidden = "wipe"
    vim.bo[prompt_buf].filetype = "inline_edit_prompt"
    local prompt_win = vim.api.nvim_open_win(prompt_buf, true, {
        relative = "win",
        win = src_win,
        bufpos = { anchor_row, 0 },
        row = 0,
        col = 0,
        width = 1,
        height = 1,
        style = "minimal",
        border = "none",
    })
    vim.wo[prompt_win].wrap = true
    vim.wo[prompt_win].linebreak = true

    ---@type InlineEditSession
    local s = {
        src_buf = src_buf,
        src_win = src_win,
        region = vim.api.nvim_buf_set_extmark(src_buf, ns, start_row, 0, { end_row = end_row, strict = false }),
        anchor_row = anchor_row,
        virt_above = virt_above,
        prompt_buf = prompt_buf,
        prompt_win = prompt_win,
        state = "idle",
    }
    session = s
    highlight(s)
    layout(s)
    scroll_into_view(s)

    vim.keymap.set("n", "<CR>", function() submit(s) end, { buffer = prompt_buf, desc = "Submit inline edit" })

    local group = vim.api.nvim_create_augroup("InlineEditPrompt", { clear = true })
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = group,
        buffer = prompt_buf,
        callback = function()
            if s.state == "failed" then
                set_state(s, "idle")
            end
            layout(s)
            scroll_into_view(s)
        end,
    })
    vim.api.nvim_create_autocmd("WinResized", {
        group = group,
        callback = function() layout(s) end,
    })
    vim.api.nvim_create_autocmd("WinClosed", {
        group = group,
        pattern = { tostring(prompt_win), tostring(src_win) },
        callback = function() vim.schedule(function() close(s) end) end,
    })
    vim.api.nvim_create_autocmd("BufUnload", {
        group = group,
        buffer = src_buf,
        callback = function() vim.schedule(function() close(s) end) end,
    })

    vim.cmd.startinsert()
end

---@param opts InlineEditConfig?
function M.setup(opts)
    options = vim.tbl_extend("force", defaults, opts or {})
    set_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", { group = augroup, callback = set_highlights })
end

return M

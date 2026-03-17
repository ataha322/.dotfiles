local M = {}

local ns_processing = vim.api.nvim_create_namespace("inline-edit-processing")

local animations = {}
local active_timers = {}
local current_animation = "shimmer"

local function stop_timer(bufnr)
    local timer = active_timers[bufnr]
    if not timer then
        return
    end

    active_timers[bufnr] = nil
    timer:stop()
    timer:close()
end

animations.shimmer = {
    interval = 120,
    groups = {
        "ShimmerDim",
        "ShimmerMid",
        "ShimmerBright",
        "ShimmerMid2",
    },
    setup = function(self)
        if self.did_setup then
            return
        end

        vim.api.nvim_set_hl(0, "ShimmerDim", { fg = "#5c6370" })
        vim.api.nvim_set_hl(0, "ShimmerMid", { fg = "#7f8ea3" })
        vim.api.nvim_set_hl(0, "ShimmerBright", { fg = "#c8d3f5" })
        vim.api.nvim_set_hl(0, "ShimmerMid2", { fg = "#9aa7bd" })

        self.did_setup = true
    end,
    render = function(self, ctx, tick)
        vim.api.nvim_buf_clear_namespace(ctx.bufnr, ns_processing, 0, -1)

        for line_nr = ctx.start_line, ctx.end_line do
            local line = vim.api.nvim_buf_get_lines(ctx.bufnr, line_nr - 1, line_nr, false)[1] or ""
            local group = self.groups[((tick + (line_nr - ctx.start_line)) % #self.groups) + 1]
            vim.api.nvim_buf_set_extmark(ctx.bufnr, ns_processing, line_nr - 1, 0, {
                end_col = #line,
                hl_group = group,
                priority = 100,
            })
        end
    end,
}

for _, animation in pairs(animations) do
    animation:setup()
end

---@param name string
function M.set_animation(name)
    if not animations[name] then
        error("Unknown inline-edit animation: " .. name)
    end

    current_animation = name
end

---@param ctx Context
function M.start(ctx)
    local animation = animations[current_animation]
    stop_timer(ctx.bufnr)

    if not vim.api.nvim_buf_is_valid(ctx.bufnr) then
        return
    end

    local timer = vim.loop.new_timer()
    local tick = 0
    active_timers[ctx.bufnr] = timer

    animation:render(ctx, tick)

    timer:start(animation.interval, animation.interval, vim.schedule_wrap(function()
        if active_timers[ctx.bufnr] ~= timer then
            return
        end

        if not vim.api.nvim_buf_is_valid(ctx.bufnr) then
            stop_timer(ctx.bufnr)
            return
        end

        tick = tick + 1
        animation:render(ctx, tick)
    end))
end

---@param bufnr number
function M.stop(bufnr)
    stop_timer(bufnr)
    if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_clear_namespace(bufnr, ns_processing, 0, -1)
    end
end

return M

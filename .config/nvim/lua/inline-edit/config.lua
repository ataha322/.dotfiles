local M = {}

---@class InlineEditLlmConfig
---@field provider string
---@field model string
---@field reasoning_effort string|nil
---@field endpoint_url string|nil
---@field temperature number|nil

---@class InlineEditContextConfig
---@field more_selected_lines number

---@class InlineEditConfig
---@field llm? InlineEditLlmConfig
---@field context? InlineEditContextConfig

---@type InlineEditConfig
local defaults = {
    llm = {
        provider = "openai",
        model = "gpt-5.3-codex",
        reasoning_effort = nil,
        endpoint_url = nil,
        temperature = 0.2,
    },
    context = {
        more_selected_lines = 0,
    }
}

---@type InlineEditConfig
M.options = vim.deepcopy(defaults)

---@param opts InlineEditConfig|nil
function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", defaults, opts or {})
end

return M

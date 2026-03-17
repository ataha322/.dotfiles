local M = {}

---@class InlineEditKeymaps
---@field open_prompt string|false Keymap to open the edit prompt (visual/normal mode)

---@class InlineEditLlmConfig
---@field provider string
---@field model string
---@field endpoint_url string|nil

---@class InlineEditContextConfig
---@field more_selected_lines number

---@class InlineEditConfig
---@field keymaps InlineEditKeymaps
---@field llm InlineEditLlmConfig
---@field context InlineEditContextConfig

---@type InlineEditConfig
local defaults = {
    keymaps = {
        open_prompt = "<leader>ae",
    },
    llm = {
        provider = "anthropic",
        model = "claude-sonnet-4-6",
        endpoint_url = nil,
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

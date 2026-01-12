local M = {}

---@class InlineEditKeymaps
---@field open_prompt string|false Keymap to open the edit prompt (visual/normal mode)
---@field accept string|false Keymap to accept change at cursor
---@field reject string|false Keymap to reject change at cursor
---@field accept_all string|false Keymap to accept all changes
---@field reject_all string|false Keymap to reject all changes

---@class InlineEditConfig
---@field keymaps InlineEditKeymaps

---@type InlineEditConfig
local defaults = {
    keymaps = {
        open_prompt = "<leader>ak",
        accept = "<D-y>",
        reject = "<D-u>",
        accept_all = "<D-S-y>",
        reject_all = "<D-S-u>",
    },
}

---@type InlineEditConfig
M.options = vim.deepcopy(defaults)

---@param opts InlineEditConfig|nil
function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", defaults, opts or {})
end

return M

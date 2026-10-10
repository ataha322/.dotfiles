local M = {}

M.inline_edit = require('ata-ai-coding.inline_edit')

---@class AtaAiCodingConfig
---@field inline_edit? InlineEditConfig

---@param opts AtaAiCodingConfig?
function M.setup(opts)
    opts = opts or {}
    M.inline_edit.setup(opts.inline_edit)
end

return M

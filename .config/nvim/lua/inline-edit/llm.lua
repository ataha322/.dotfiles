local M = {}

local config = require('inline-edit.config')
local anthropic = require('inline-edit.llm.anthropic')
local openai = require('inline-edit.llm.openai')

local providers = {
    anthropic = anthropic,
    openai = openai,
}

---@param prompt string
---@param context Context
---@param on_success fun(response: string)
---@param on_error fun(err: string)
function M.call(prompt, context, on_success, on_error)
    local provider = config.options.llm.provider
    local endpoint_url = config.options.llm.endpoint_url
    local client = providers[provider]

    if not client then
        on_error("Unsupported LLM provider: " .. tostring(provider))
        return
    end

    local system_prompt =
    [[You are a code editing assistant. You will be given code context wrapped in <user_code>...</user_code> tags.
It will contain:
1. Code before the selection
2. The selection to edit (wrapped in <selection>...</selection> tags)
3. Code after the selection
4. User's prompt (wrapped in <prompt>...</prompt> tags)

Your task is edit the selection or provide new code that will go into the selection.
Wrap your code response in <code></code> tags. Only include the code that will be inserted into the selection, no explanations.
ONLY RESPOND WITH ONE <code>...</code> block.]]

    local llm_prompt = string.format(
        [[<user_code>
%s
<selection>
%s
</selection>
%s
<prompt>
%s
</prompt>
</user_code>]],
        table.concat(context.lines_before, "\n"),
        table.concat(context.original_lines, "\n"),
        table.concat(context.lines_after, "\n"),
        prompt
    )

    client.call(system_prompt, llm_prompt, config.options.llm.model, endpoint_url, on_success, on_error)
end

return M

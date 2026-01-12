local M = {}
local curl = require('plenary.curl')
local logging = require('inline-edit.logging')
local api_key = os.getenv("ANTHROPIC_API_KEY")

---@param prompt string
---@param context Context
---@param on_success fun(response: string)
---@param on_error fun(err: string)
function M.call(prompt, context, on_success, on_error)
    if not api_key then
        on_error("ANTHROPIC_API_KEY environment variable not set")
        return
    end

    -- Build the system prompt with context
    local system_prompt = string.format([[You are a code editing assistant. You will be given:
1. Code before the selection (for context)
2. The selection to edit (may be empty)
3. Code after the selection (for context)
4. User's prompt (may be empty)

Your task is edit the selection or provide new code that will go into the selection.
Wrap your code response in <code></code> tags. Only include the code, no explanations.
Even when input prompt is invalid, always respond with code inside <code></code> tags.

Context before:
```
%s
```

Selected code:
```
%s
```

Context after:
```
%s
```]],
        table.concat(context.lines_before, "\n"),
        table.concat(context.original_lines, "\n"),
        table.concat(context.lines_after, "\n")
    )

    -- Build request body
    local request_body = {
        model = "claude-haiku-4-5",
        max_tokens = 2048,
        system = system_prompt,
        messages = {
            {
                role = "user",
                content = prompt
            }
        }
    }

    logging.log("Request body: " .. vim.inspect(request_body))

    curl.post("https://api.anthropic.com/v1/messages", {
        headers = {
            ["content-type"] = "application/json",
            ["x-api-key"] = api_key,
            ["anthropic-version"] = "2023-06-01"
        },
        body = vim.fn.json_encode(request_body),
        callback = function(response)
            vim.schedule(function()
                if response.status ~= 200 then
                    on_error("API request failed with status " .. response.status .. ": " .. response.body)
                    return
                end

                local ok, decoded = pcall(vim.fn.json_decode, response.body)
                if not ok then
                    on_error("Failed to parse API response: " .. response.body)
                    return
                end

                if decoded.error then
                    on_error("API error: " .. vim.inspect(decoded.error))
                    return
                end

                logging.log("Decoded response: " .. vim.inspect(decoded))
                -- Extract the text content from the response
                if decoded.content and decoded.content[1] and decoded.content[1].text then
                    on_success(decoded.content[1].text)
                else
                    on_error("Unexpected API response format: " .. vim.inspect(decoded))
                end
            end)
        end
    })
end

return M

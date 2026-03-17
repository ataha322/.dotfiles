local M = {}

local curl = require('plenary.curl')

function M.call(system_prompt, prompt, model, _, on_success, on_error)
    local api_key = os.getenv("ANTHROPIC_API_KEY")

    if not api_key then
        on_error("ANTHROPIC_API_KEY environment variable not set")
        return
    end

    local request_body = {
        model = model or "claude-haiku-4-5",
        max_tokens = 4096,
        system = system_prompt,
        messages = {
            {
                role = "user",
                content = prompt
            }
        }
    }

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

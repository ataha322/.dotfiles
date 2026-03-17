local M = {}

local curl = require('plenary.curl')

function M.call(system_prompt, prompt, model, endpoint_url, on_success, on_error)
    local api_key = os.getenv("OPENAI_API_KEY")

    if not api_key then
        on_error("OPENAI_API_KEY environment variable not set")
        return
    end

    local request_body = {
        model = model or "gpt-5.1-codex-mini",
        messages = {
            {
                role = "system",
                content = system_prompt
            },
            {
                role = "user",
                content = prompt
            }
        }
    }

    curl.post(endpoint_url or "https://api.openai.com/v1/chat/completions", {
        headers = {
            ["content-type"] = "application/json",
            ["authorization"] = "Bearer " .. api_key
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

                if decoded.choices and decoded.choices[1] and decoded.choices[1].message and decoded.choices[1].message.content then
                    on_success(decoded.choices[1].message.content)
                else
                    on_error("Unexpected API response format: " .. vim.inspect(decoded))
                end
            end)
        end
    })
end

return M

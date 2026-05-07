local M = {}

local curl = require('plenary.curl')
local config = require('inline-edit.config')

local provider_defaults = {
    openai = {
        api_key_env = "OPENAI_API_KEY",
        endpoint_url = "https://api.openai.com/v1/chat/completions",
        model = "gpt-5.3-codex",
    },
    cerebras = {
        api_key_env = "CEREBRAS_API_KEY",
        endpoint_url = "https://api.cerebras.ai/v1/chat/completions",
        model = "gpt-oss-120b",
    },
}

function M.call(system_prompt, prompt, model, reasoning_effort, endpoint_url, temperature, on_success, on_error)
    local provider = config.options.llm.provider
    local defaults = provider_defaults[provider] or provider_defaults.openai
    local api_key = os.getenv(defaults.api_key_env)

    if not api_key then
        on_error(defaults.api_key_env .. " environment variable not set")
        return
    end

    local request_body = {
        model = model or defaults.model,
        reasoning_effort = reasoning_effort,
        temperature = temperature,
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

    curl.post(endpoint_url or defaults.endpoint_url, {
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

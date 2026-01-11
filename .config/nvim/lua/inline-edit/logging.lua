local M = {}

function M.log(message)
    local log_path = vim.fn.stdpath("data") .. "/inline-edit.log"
    local file = io.open(log_path, "a")
    if file then
        file:write(os.date("[%Y-%m-%d %H:%M:%S] ") .. message .. "\n")
        file:close()
    end
end

return M

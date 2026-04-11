local M = {}

local working_buf = nil

function M.toggle_notes_buffer(file_path)
    local abs_path = vim.fn.fnamemodify(file_path, ":p")
    local cur_buf = vim.api.nvim_get_current_buf()

    if vim.bo[cur_buf].filetype == "ata_notes" and vim.api.nvim_buf_get_name(cur_buf) == abs_path then
        if working_buf and vim.api.nvim_buf_is_valid(working_buf) then
            vim.api.nvim_set_current_buf(working_buf)
        else
            vim.cmd("b#")
        end
        return
    end

    if vim.bo[cur_buf].filetype ~= "ata_notes" then
        working_buf = cur_buf
    end

    local note_buf = vim.fn.bufadd(abs_path)
    vim.fn.bufload(note_buf)
    vim.api.nvim_set_current_buf(note_buf)
    vim.bo[note_buf].filetype = "ata_notes"
end

return M

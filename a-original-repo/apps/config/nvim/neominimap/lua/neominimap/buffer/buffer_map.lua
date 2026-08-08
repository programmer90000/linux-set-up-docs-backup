local M = {}

local api = vim.api

local bufnr_to_mbufnr = {}

M.get_source_bufnr = function(mbufnr)
    for bufnr, mbufnr_ in pairs(bufnr_to_mbufnr) do
        if mbufnr_ == mbufnr then
            return bufnr
        end
    end
    return nil
end

M.is_minimap_buffer = function(bufnr)
    return M.get_source_bufnr(bufnr) ~= nil
end

M.get_minimap_bufnr = function(bufnr)
    local mbufnr = bufnr_to_mbufnr[bufnr]
    if mbufnr ~= nil and not api.nvim_buf_is_valid(mbufnr) then
        bufnr_to_mbufnr[bufnr] = nil
        return nil
    end
    return mbufnr
end

M.set_minimap_bufnr = function(bufnr, mbufnr)
    bufnr_to_mbufnr[bufnr] = mbufnr
end

M.list_buffers = function()
    return vim.tbl_keys(bufnr_to_mbufnr)
end

return M

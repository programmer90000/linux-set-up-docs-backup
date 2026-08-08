local M = {}

local refresh_all = vim.schedule_wrap(function()
    require("neominimap.buffer.internal").refresh_all_minimap_buffers()
end)

local refresh = vim.schedule_wrap(function(bufnr)
    require("neominimap.buffer.internal").refresh_minimap_buffer(bufnr)
end)

M.buf_apis = {
    ["enable"] = refresh,
    ["disable"] = refresh,
    ["refresh"] = refresh,
}

M.global_apis = {
    ["enable"] = refresh_all,
    ["disable"] = refresh_all,
    ["refresh"] = refresh_all,
}

return M

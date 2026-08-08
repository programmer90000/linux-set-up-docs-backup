local api = vim.api

local M = {}

M.enable = function()
    local winid = api.nvim_get_current_win()
    require("neominimap.window").get_focus_apis().focus(winid)
end

M.disable = function()
    local winid = api.nvim_get_current_win()
    require("neominimap.window").get_focus_apis().unfocus(winid)
end

M.toggle = function()
    local winid = api.nvim_get_current_win()
    require("neominimap.window").get_focus_apis().toggle_focus(winid)
end

return M

local M = {}

local api = vim.api

local tabid_to_mwinid = {}

local tabid_to_swinid = {}

M.get_minimap_winid = function(tabid)
    local mwinid = tabid_to_mwinid[tabid]
    if mwinid ~= nil and not api.nvim_win_is_valid(mwinid) then
        local logger = require("neominimap.logger")
        tabid_to_mwinid[tabid] = nil
        return nil
    end
    return mwinid
end

M.set_minimap_winid = function(tabid, mwinid)
    tabid_to_mwinid[tabid] = mwinid
end

M.get_source_winid = function(tabid)
    local swinid = tabid_to_swinid[tabid]
    if swinid ~= nil and not api.nvim_win_is_valid(swinid) then
        tabid_to_swinid[tabid] = nil
        return nil
    end
    return swinid
end

M.set_source_winid = function(tabid, swinid)
    tabid_to_swinid[tabid] = swinid
end

M.is_minimap_window = function(tabid, mwinid)
    return mwinid ~= nil and tabid_to_mwinid[tabid] == mwinid
end

return M

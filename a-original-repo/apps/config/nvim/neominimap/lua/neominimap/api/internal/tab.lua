local api = vim.api

local function enable(tabid)
    local var = require("neominimap.variables")
    var.t[tabid].enabled = true
    require("neominimap.window").get_tab_apis().enable(tabid)
end

local function disable(tabid)
    local var = require("neominimap.variables")
    var.t[tabid].enabled = false
    require("neominimap.window").get_tab_apis().disable(tabid)
end

local function enabled(tabid)
    local var = require("neominimap.variables")
    if not tabid then
        tabid = api.nvim_get_current_tabpage()
    end
    return var.t[tabid].enabled
end

local function toggle(tabid)
    local var = require("neominimap.variables")
    if var.t[tabid].enabled then
        disable(tabid)
    else
        enable(tabid)
    end
end

local function refresh(tabid)
    require("neominimap.window").get_tab_apis().refresh(tabid)
end

local valid_tab_list = function(tab_list)
    local is_valid, err = require("neominimap.api.util").validate_list_of_integers(tab_list)
    if not is_valid then
        return false, err
    end
    for _, tabid in ipairs(tab_list) do
        if not api.nvim_tabpage_is_valid(tabid) then
            return false, string.format("Tab %d is not valid.", tabid)
        end
    end
    return true
end

local wrap_tab_function = function(func)
    return function(tab_list)
        if tab_list == nil then
            tab_list = { api.nvim_get_current_tabpage() }
        elseif type(tab_list) ~= "table" then
            tab_list = { tab_list }
        end
        local is_valid, err = valid_tab_list(tab_list)
        if not is_valid then
            error(err)
        end
        vim.tbl_map(func, tab_list)
    end
end

return {
    enable = wrap_tab_function(enable),
    disable = wrap_tab_function(disable),
    enabled = enabled,
    toggle = wrap_tab_function(toggle),
    refresh = wrap_tab_function(refresh),
}

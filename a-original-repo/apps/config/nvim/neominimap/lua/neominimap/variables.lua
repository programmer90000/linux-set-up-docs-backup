local VariableManager = {}
VariableManager.__index = VariableManager

local function prefixed_name(name)
    return "neominimap_" .. name
end

function VariableManager.new(scope, default)
    return setmetatable({
        scope = scope,
        default = default,
    }, VariableManager)
end

function VariableManager:set_var(id, name, value)
    local key = prefixed_name(name)
    local scope = id == nil and self.scope or self.scope[id]
    scope[key] = value
end

function VariableManager:get_var(id, name)
    local key = prefixed_name(name)
    local scope = id == nil and self.scope or self.scope[id]
    if scope[key] == nil then
        scope[key] = self.default[name]
    end
    return scope[key]
end

function VariableManager:get_instance(id)
    return setmetatable({}, {
        __index = function(_, k)
            return self:get_var(id, k)
        end,
        __newindex = function(_, k, v)
            self:set_var(id, k, v)
        end,
    })
end

function VariableManager:global_table()
    return setmetatable({}, {
        __index = function(_, k)
            if type(k) == "number" then
                return self:get_instance(k)
            else
                return self:get_var(nil, k)
            end
        end,
        __newindex = function(_, k, v)
            self:set_var(nil, k, v)
        end,
    })
end

local global_default = {
    enabled = require("neominimap.config").auto_enable,
}

local buffer_default = {
    enabled = true,
    render = function() end,
    update_handler = {},
    cached_folds = {},
    diagnostics = {},
}

local window_default = {
    enabled = true,
}

local tabpage_default = {
    enabled = true,
}

local global = VariableManager.new(vim.g, global_default)
local buffer = VariableManager.new(vim.b, buffer_default)
local window = VariableManager.new(vim.w, window_default)
local tabpage = VariableManager.new(vim.t, tabpage_default)

return {
    g = global:global_table(),
    b = buffer:global_table(),
    w = window:global_table(),
    t = tabpage:global_table(),
    set_var = global.set_var,
    get_var = global.get_var,
    buffer_set_var = buffer.set_var,
    buffer_get_var = buffer.get_var,
    window_set_var = window.set_var,
    window_get_var = window.get_var,
    tab_set_var = tabpage.set_var,
    tab_get_var = tabpage.get_var,
}

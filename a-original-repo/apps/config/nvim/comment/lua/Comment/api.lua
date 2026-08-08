local Config = require('Comment.config')
local U = require('Comment.utils')
local Op = require('Comment.opfunc')
local Ex = require('Comment.extra')
local A = vim.api

local api, core = {}, {}

function core.__index(that, ctype)
    local idxd = {}
    local mode, type = that.cmode, U.ctype[ctype]
    
    ---To comment the current-line
    function idxd.current(_, cfg)
        U.catch(Op.opfunc, nil, cfg or Config:get(), mode, type)
    end
    
    ---To comment lines with a count
    function idxd.count(count, cfg)
        U.catch(Op.count, count or A.nvim_get_vvar('count'), cfg or Config:get(), mode, type)
    end
    
    function idxd.count_repeat(_, count, cfg)
        idxd.count(count, cfg)
    end
    
    return setmetatable({}, {
        __index = idxd,
        __call = function(_, motion, cfg)
            U.catch(Op.opfunc, motion, cfg or Config:get(), mode, type)
        end,
    })
end

api.toggle = setmetatable({ cmode = U.cmode.toggle }, core)

api.comment = setmetatable({ cmode = U.cmode.comment }, core)

api.uncomment = setmetatable({ cmode = U.cmode.uncomment }, core)

api.insert = setmetatable({}, {
    __index = function(_, ctype)
        return {
            above = function(cfg)
                U.catch(Ex.insert_above, U.ctype[ctype], cfg or Config:get())
            end,
            below = function(cfg)
                U.catch(Ex.insert_below, U.ctype[ctype], cfg or Config:get())
            end,
            eol = function(cfg)
                U.catch(Ex.insert_eol, U.ctype[ctype], cfg or Config:get())
            end,
        }
    end,
})

function api.locked(cb)
    return function(motion)
        return A.nvim_command(
            ('lockmarks lua require("Comment.api").%s(%s)'):format(cb, motion and ('%q'):format(motion))
        )
    end
end

function api.call(cb, op)
    return function()
        A.nvim_set_option('operatorfunc', ("v:lua.require'Comment.api'.locked'%s'"):format(cb))
        Config.position = Config:get().sticky and A.nvim_win_get_cursor(0) or nil
        return op
    end
end

return api

return {
    enable = function()
        require("neominimap.api.internal.global").enable()
    end,
    disable = function()
        require("neominimap.api.internal.global").disable()
    end,
    enabled = function()
        return require("neominimap.api.internal.global").enabled()
    end,
    toggle = function()
        require("neominimap.api.internal.global").toggle()
    end,
    refresh = function()
        require("neominimap.api.internal.global").refresh()
    end,
    
    buf = {
        enable = function(buf_list)
            require("neominimap.api.internal.buf").enable(buf_list)
        end,
        disable = function(buf_list)
            require("neominimap.api.internal.buf").disable(buf_list)
        end,
        enabled = function(bufnr)
            return require("neominimap.api.internal.buf").enabled(bufnr)
        end,
        toggle = function(buf_list)
            require("neominimap.api.internal.buf").toggle(buf_list)
        end,
        refresh = function(buf_list)
            require("neominimap.api.internal.buf").refresh(buf_list)
        end,
    },
    
    win = {
        enable = function(win_list)
            require("neominimap.api.internal.win").enable(win_list)
        end,
        disable = function(win_list)
            require("neominimap.api.internal.win").disable(win_list)
        end,
        enabled = function(winid)
            return require("neominimap.api.internal.win").enabled(winid)
        end,
        toggle = function(win_list)
            require("neominimap.api.internal.win").toggle(win_list)
        end,
        refresh = function(win_list)
            require("neominimap.api.internal.win").refresh(win_list)
        end,
    },
    
    tab = {
        enable = function(tab_list)
            require("neominimap.api.internal.tab").enable(tab_list)
        end,
        disable = function(tab_list)
            require("neominimap.api.internal.tab").disable(tab_list)
        end,
        enabled = function(tabid)
            return require("neominimap.api.internal.tab").enabled(tabid)
        end,
        toggle = function(tab_list)
            require("neominimap.api.internal.tab").toggle(tab_list)
        end,
        refresh = function(tab_list)
            require("neominimap.api.internal.tab").refresh(tab_list)
        end,
    },
    
    focus = {
        enable = function()
            require("neominimap.api.internal.focus").enable()
        end,
        disable = function()
            require("neominimap.api.internal.focus").disable()
        end,
        toggle = function()
            require("neominimap.api.internal.focus").toggle()
        end,
    },
}

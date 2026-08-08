---@class Neominimap.Internal.Config
local M = {
    auto_enable = true,
    log_level = vim.log.levels.OFF,
    notification_level = vim.log.levels.INFO,
    log_path = vim.fn.stdpath("data") .. "/neominimap.log",
    exclude_filetypes = {
        "help",
        "bigfile",
    },
    exclude_buftypes = {
        "nofile",
        "nowrite",
        "quickfix",
        "terminal",
        "prompt",
    },
    
    buf_filter = function()
        return true
    end,
    win_filter = function()
        return true
    end,
    tab_filter = function()
        return true
    end,
    
    x_multiplier = 4,
    y_multiplier = 1,
    
    current_line_position = "center",
    
    buffer = {
        persist = true,
    },
    
    layout = "float",
    
    split = {
        minimap_width = 20,
        fix_width = false,
        direction = "right",
        close_if_last_window = true,
        persist = false,
    },
    float = {
        minimap_width = 20,
        max_minimap_height = nil,
        margin = {
            right = 0,
            top = 0,
            bottom = 0,
        },
        z_index = 1,
        
        window_border = vim.fn.has("nvim-0.11") == 1 and vim.o.winborder or "single",
        persist = false,
    },
    
    delay = 200,
    
    sync_cursor = true,

    click = {
        enabled = true,
        auto_switch_focus = true,
    },

    diagnostic = {
        enabled = false,
        
        severity = nil,
        mode = "line",
        priority = {
            ERROR = 100,
            WARN = 90,
            INFO = 80,
            HINT = 70,
        },
        icon = {
            ERROR = "󰅚 ",
            WARN = "󰀪 ",
            INFO = "󰌶 ",
            HINT = " ",
        },
    },
    
    git = {
        enabled = true,
        mode = "sign",
        priority = 6,
        icon = {
            add = "+ ",
            change = "~ ",
            delete = "- ",
        },
    },
    
    mini_diff = {
        enabled = false,
        mode = "sign",
        priority = 6,
        icon = {
            add = "+ ",
            change = "~ ",
            delete = "- ",
        },
    },
    
    search = {
        enabled = false,
        mode = "line",
        priority = 20,
        icon = "󰱽 ",
    },
    
    treesitter = {
        enabled = true,
        priority = 200,
    },
    
    mark = {
        enabled = false,
        mode = "icon",
        priority = 10,
        key = "m",
        show_builtins = false,
    },
    
    fold = {
        enabled = true,
    },
    
    winopt = function(opt, winid) end,
    bufopt = function(opt, bufnr) end,
    handlers = {},
}

function M:get_minimap_width()
    return self[self.layout].minimap_width
end

return M

local config = require("neominimap.config")

local api = vim.api

api.nvim_set_hl(0, "NeominimapBackground", { link = "Normal", default = true })
api.nvim_set_hl(0, "NeominimapBorder", { link = "FloatBorder", default = true })
api.nvim_set_hl(0, "NeominimapCursorLine", { link = "CursorLine", default = true })
api.nvim_set_hl(0, "NeominimapCursorLineSign", { link = "CursorLineSign", default = true })
api.nvim_set_hl(0, "NeominimapCursorLineNr", { link = "CursorLineSign", default = true })
api.nvim_set_hl(0, "NeominimapCursorLineFold", { link = "CursorLineSign", default = true })

local tbl = {
    ["float"] = function()
        return require("neominimap.window.float")
    end,
    ["split"] = function()
        return require("neominimap.window.split")
    end,
}

return tbl[config.layout]()

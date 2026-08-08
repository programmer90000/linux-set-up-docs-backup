local M = {}

M.refresh = function(args, opts)
    local msg =
        vim.deprecate("require('neominimap').refresh", "require('neominimap.api').refresh", "v4", "neominimap.nvim")
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.global").subcommand_tbl.refresh.impl(args, opts)
end

M.on = function(args, opts)
    local msg = vim.deprecate("require('neominimap').on", "require('neominimap.api').enable", "v4", "neominimap.nvim")
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.global").subcommand_tbl.on.impl(args, opts)
end

M.off = function(args, opts)
    local msg = vim.deprecate("require('neominimap').off", "require('neominimap.api').disable", "v4", "neominimap.nvim")
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.global").subcommand_tbl.off.impl(args, opts)
end

M.toggle = function(args, opts)
    local msg =
        vim.deprecate("require('neominimap').toggle", "require('neominimap.api').toggle", "v4", "neominimap.nvim")
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.global").subcommand_tbl.toggle.impl(args, opts)
end

M.enabled = function()
    local msg =
        vim.deprecate("require('neominimap').enabled", "require('neominimap.api').enabled", "v4", "neominimap.nvim")
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    return require("neominimap.variables").g.enabled
end

M.bufOn = function(args, opts)
    local msg =
        vim.deprecate("require('neominimap').bufOn", "require('neominimap.api').buf.enable", "v4", "neominimap.nvim")
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.buf").subcommand_tbl.bufOn.impl(args, opts)
end

M.bufOff = function(args, opts)
    local msg =
        vim.deprecate("require('neominimap').bufOff", "require('neominimap.api').buf.disable", "v4", "neominimap.nvim")
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.buf").subcommand_tbl.bufOff.impl(args, opts)
end

M.bufToggle = function(args, opts)
    local msg = vim.deprecate(
        "require('neominimap').bufToggle",
        "require('neominimap.api').buf.toggle",
        "v4",
        "neominimap.nvim"
    )
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.buf").subcommand_tbl.bufToggle.impl(args, opts)
end

M.bufRefresh = function(args, opts)
    local msg = vim.deprecate(
        "require('neominimap').bufRefresh",
        "require('neominimap.api').buf.refresh",
        "v4",
        "neominimap.nvim"
    )
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.buf").subcommand_tbl.bufRefresh.impl(args, opts)
end

M.bufEnabled = function(bufnr)
    local msg = vim.deprecate(
        "require('neominimap').bufEnabled",
        "require('neominimap.api').buf.enabled",
        "v4",
        "neominimap.nvim"
    )
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    if bufnr == nil then
        bufnr = 0
    end
    return require("neominimap.variables").b[bufnr].enabled
end

M.winOn = function(args, opts)
    local msg =
        vim.deprecate("require('neominimap').winOn", "require('neominimap.api').win.enable", "v4", "neominimap.nvim")
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.win").subcommand_tbl.winOn.impl(args, opts)
end

M.winOff = function(args, opts)
    local msg =
        vim.deprecate("require('neominimap').winOff", "require('neominimap.api').win.disable", "v4", "neominimap.nvim")
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.win").subcommand_tbl.winOff.impl(args, opts)
end

M.winToggle = function(args, opts)
    local msg = vim.deprecate(
        "require('neominimap').winToggle",
        "require('neominimap.api').win.toggle",
        "v4",
        "neominimap.nvim"
    )
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.win").subcommand_tbl.winToggle.impl(args, opts)
end

M.winRefresh = function(args, opts)
    local msg = vim.deprecate(
        "require('neominimap').winRefresh",
        "require('neominimap.api').win.refresh",
        "v4",
        "neominimap.nvim"
    )
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.win").subcommand_tbl.winRefresh.impl(args, opts)
end

M.tabOn = function(args, opts)
    local msg =
        vim.deprecate("require('neominimap').tabOn", "require('neominimap.api').tab.enable", "v4", "neominimap.nvim")
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.tab").subcommand_tbl.tabOn.impl(args, opts)
end

M.tabOff = function(args, opts)
    local msg =
        vim.deprecate("require('neominimap').tabOff", "require('neominimap.api').tab.disable", "v4", "neominimap.nvim")
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.tab").subcommand_tbl.tabOff.impl(args, opts)
end

M.winEnabled = function(winid)
    local msg = vim.deprecate(
        "require('neominimap').winEnabled",
        "require('neominimap.api').win.enabled",
        "v4",
        "neominimap.nvim"
    )
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    if winid == nil then
        winid = 0
    end
    return require("neominimap.variables").w[winid].enabled
end

M.tabToggle = function(args, opts)
    local msg = vim.deprecate(
        "require('neominimap').tabToggle",
        "require('neominimap.api').tab.toggle",
        "v4",
        "neominimap.nvim"
    )
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.tab").subcommand_tbl.tabToggle.impl(args, opts)
end

M.tabRefresh = function(args, opts)
    local msg = vim.deprecate(
        "require('neominimap').tabRefresh",
        "require('neominimap.api').tab.refresh",
        "v4",
        "neominimap.nvim"
    )
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.tab").subcommand_tbl.tabRefresh.impl(args, opts)
end

M.tabEnabled = function(tabid)
    local msg = vim.deprecate(
        "require('neominimap').tabEnabled",
        "require('neominimap.api').tab.enabled",
        "v4",
        "neominimap.nvim"
    )
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    if tabid == nil then
        tabid = 0
    end
    return require("neominimap.variables").t[tabid].enabled
end

M.focus = function(args, opts)
    local msg =
        vim.deprecate("require('neominimap').focus", "require('neominimap.api').focus.on", "v4", "neominimap.nvim")
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.focus").subcommand_tbl.focus.impl(args, opts)
end

M.unfocus = function(args, opts)
    local msg =
        vim.deprecate("require('neominimap').unfocus", "require('neominimap.api').focus.off", "v4", "neominimap.nvim")
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.focus").subcommand_tbl.unfocus.impl(args, opts)
end

M.toggleFocus = function(args, opts)
    local msg = vim.deprecate(
        "require('neominimap').toggleFocus",
        "require('neominimap.api').focus.toggle",
        "v4",
        "neominimap.nvim"
    )
    if msg then
        local logger = require("neominimap.logger")
        logger.notify(msg, vim.log.levels.WARN)
    end
    require("neominimap.command.focus").subcommand_tbl.toggleFocus.impl(args, opts)
end

return M

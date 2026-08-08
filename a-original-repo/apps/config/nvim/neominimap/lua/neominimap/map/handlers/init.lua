local M = {}
local api = vim.api
local config = require("neominimap.config")

local handlers = {}

M.get_handlers = function()
    return handlers
end

M.register = function(handler)
    handler.init()
    handlers[#handlers + 1] = handler
end

M.create_autocmds = function(group)
    vim.tbl_map(function(handler)
        vim.tbl_map(function(autocmd)
            local opts = autocmd.opts
            local callback = function(args)
                vim.schedule(function()
                    local apply = require("neominimap.buffer").apply_handler
                    if opts.callback then
                        opts.callback(function(bufnr)
                            apply(bufnr, handler.name)
                        end, args)
                    else
                        local target = opts.get_buffers(args)
                        local logger = require("neominimap.logger")
                        logger.log.trace("Applying handler {} to buffer(s) %s", handler.name, vim.inspect(target))
                        if type(target) == "table" then
                            vim.tbl_map(function(bufnr)
                                apply(bufnr, handler.name)
                            end, target)
                        elseif target then
                            apply(target, handler.name)
                        end
                    end
                end)
            end
            api.nvim_create_autocmd(autocmd.event, {
                group = group,
                pattern = opts.pattern,
                desc = opts.desc,
                callback = callback,
            })
        end, handler.autocmds)
    end, handlers)
end

M.apply = function(bufnr, mbufnr, namespace, annotations, mode)
    require("neominimap.map.handlers.application").apply(bufnr, mbufnr, namespace, annotations, mode)
end

local builtins = require("neominimap.map.handlers.builtins")

for name, handler in pairs(builtins) do
    if config[name].enabled then
        M.register(handler)
    end
end

vim.tbl_map(M.register, config.handlers)

return M

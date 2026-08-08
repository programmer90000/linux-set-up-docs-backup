local M = {}

M.resume = function(co, ...)
    local thread_table = require("neominimap.cooperative.thread_table")
    if not thread_table[co] then
        return
    end
    local status, result = coroutine.resume(co, ...)
    if not status then
        local logger = require("neominimap.logger")
        logger.notify("Error in coroutine: " .. result, vim.log.levels.ERROR)
        thread_table[co] = nil
        return
    end
    if coroutine.status(co) == "dead" then
        thread_table[co] = nil
    end
end

M.defer_co = function()
    local co = coroutine.running()
    vim.defer_fn(function()
        M.resume(co)
    end, 0)
    return coroutine.yield()
end

M.for_co = function(start, stop, step, batch_size, func)
    for i = start, stop, step do
        func(i)

        if (i - start) % batch_size == 0 then
            M.defer_co()
        end
    end
end

M.for_co_wrapped = function(start, stop, step, batch_size, func)
    return function()
        M.for_co(start, stop, step, batch_size, func)
    end
end

M.for_in_co = function(iterator, invariant, start_index)
    return function(batch_size, func)
        local count = 0
        for key, value in iterator, invariant, start_index do
            func(key, value)

            count = count + 1
            if count == batch_size then
                M.defer_co()
                count = 0
            end
        end
    end
end

M.for_in_co_wrapped = function(iterator, invariant, start_index)
    return function(batch_size, func)
        return function()
            M.for_in_co(iterator, invariant, start_index)(batch_size, func)
        end
    end
end

M.while_co = function(condition, batch_size, func)
    local count = 0
    while condition() do
        func()
        
        count = count + 1
        if count == batch_size then
            M.defer_co()
            count = 0
        end
    end
end

M.while_co_wrapped = function(condition, batch_size, func)
    return function()
        M.while_co(condition, batch_size, func)
    end
end

return M

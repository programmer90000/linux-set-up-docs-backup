local M = {}
local config = require("neominimap.config")
local levels = vim.log.levels

local level_names = {
    [levels.TRACE] = "TRACE",
    [levels.DEBUG] = "DEBUG",
    [levels.INFO] = "INFO",
    [levels.WARN] = "WARN",
    [levels.ERROR] = "ERROR",
    [levels.OFF] = "OFF",
}

local function format_message(template, ...)
    local args = { ... }
    local n_args = #args
    if n_args == 0 then
        return tostring(template)
    else
        table.insert(args, 1, template)
        local success, result = pcall(string.format, unpack(args))
        if success then
            return result
        else
            local parts = vim.tbl_map(tostring, args)
            local error_msg = tostring(result)
            return string.format("[FORMAT ERROR: %s | Args: %s]", error_msg, table.concat(parts, ", "))
        end
    end
end

local function log(caller_level, level, template, ...)
    local msg = format_message(template, ...)
    local filename = config.log_path
    local time = os.date("%Y-%m-%d %H:%M:%S")
    local f, _ = io.open(filename, "a")
    if not f then
        M.notify("Error: Could not open log file at " .. filename, levels.ERROR)
        return
    end
    local info = debug.getinfo(caller_level, "Sl")
    local log_message = string.format(
        "[%s] [%-5s] [%s:%d] %s\n",
        time,
        level_names[level] or "?????",
        info.short_src or "unknown",
        info.currentline or 0,
        msg
    )
    local ok_write, err_write = f:write(log_message)
    f:close()
    if not ok_write then
        M.notify(
            string.format("Error writing to log file %s: %s", filename, err_write or "unknown error"),
            levels.ERROR
        )
    end
end

M.log = {}

for level = levels.TRACE, levels.ERROR do
    local lower_name = string.lower(level_names[level])
    if level >= config.log_level then
        M.log[lower_name] = function(template, ...)
            log(3, level, template, ...)
        end
    else
        M.log[lower_name] = function() end
    end
end

setmetatable(M.log, {
    __index = M.log,
    
    __call = function(self, msg, level)
        level = level or levels.INFO
        if level < config.log_level then
            return
        end
        log(3, level, msg)
    end,
})

function M.notify(msg, level)
    level = level or levels.INFO
    if level >= config.notification_level then
        vim.notify(msg, level)
    end
end

return M

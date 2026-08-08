local M = {}
local api, fn = vim.api, vim.fn

M.capitalize = function(word)
    return word:sub(1, 1):upper() .. word:sub(2)
end

M.get_visible_buffers = function()
    local visible_buffers = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        table.insert(visible_buffers, buf)
    end
    return visible_buffers
end

M.get_attached_window = function(bufnr)
    local win_list = api.nvim_list_wins()
    
    local attached_window = {}
    for _, w in ipairs(win_list) do
        if api.nvim_win_get_buf(w) == bufnr then
            attached_window[#attached_window + 1] = w
        end
    end
    
    return attached_window
end

M.is_floating = function(winid)
    return api.nvim_win_get_config(winid).relative ~= ""
end

M.for_all_buffers = function(f)
    local buffer_list = api.nvim_list_bufs()
    vim.tbl_map(f, buffer_list)
end

M.for_all_windows = function(f)
    local win_list = api.nvim_list_wins()
    vim.tbl_map(f, win_list)
end

M.for_all_windows_in_tab = function(f, tabid)
    local win_list = api.nvim_tabpage_list_wins(tabid)
    vim.tbl_map(f, win_list)
end

M.for_all_tabs = function(f)
    local tab_list = api.nvim_list_tabpages()
    vim.tbl_map(f, tab_list)
end

M.is_search_mode = function()
    if
        vim.o.incsearch
        and vim.o.hlsearch
        and api.nvim_get_mode().mode == "c"
        and vim.tbl_contains({ "/", "?" }, fn.getcmdtype())
    then
        return true
    end
    return false
end

function M.noautocmd(f)
    return function(...)
        local eventignore = vim.o.eventignore
        vim.o.eventignore = "all"
        local r = { pcall(f, ...) }
        vim.o.eventignore = eventignore
        if not r[1] then
            error(r[2])
        end
        return unpack(r, 2, table.maxn(r))
    end
end

function M.on_cmd(cmd, augroup, f)
    api.nvim_create_autocmd("CmdlineLeave", {
        group = augroup,
        callback = function()
            if fn.getcmdtype() == ":" and vim.startswith(fn.getcmdline(), cmd) then
                f()
            end
        end,
    })
end

M.debounce = function(f, delay)
    local timer = vim.uv.new_timer()
    assert(timer, "Failed to create uv timer")
    return function(...)
        local args = { ... }
        timer:stop()
        timer:start(delay, 0, function()
            vim.schedule(function()
                f(unpack(args))
            end)
        end)
    end
end

M.finally = function(f, callback)
    return function(...)
        local args = { ... }
        local ret = f(unpack(args))
        callback()
        return ret
    end
end

M.lower_bound = function(arr, value)
    local low, high = 1, #arr + 1

    while low < high do
        local mid = bit.rshift(low + high, 1)
        if arr[mid] < value then
            low = mid + 1
        else
            high = mid
        end
    end

    return low
end

M.upper_bound = function(arr, value)
    local low, high = 1, #arr + 1
    
    while low < high do
        local mid = bit.rshift(low + high, 1)
        if arr[mid] <= value then
            low = mid + 1
        else
            high = mid
        end
    end
    
    return low
end

return M

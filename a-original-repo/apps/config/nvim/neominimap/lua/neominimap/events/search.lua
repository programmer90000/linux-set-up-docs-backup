local api, fn = vim.api, vim.fn

local function exec_autocmd(data)
    api.nvim_exec_autocmds("User", {
        pattern = "Search",
        data = data,
        group = "Neominimap",
    })
end

local last_hlsearch = vim.v.hlsearch

local interval = math.min(vim.o.updatetime, 1000)

local function check_hlsearch()
    if vim.v.hlsearch ~= last_hlsearch then
        last_hlsearch = vim.v.hlsearch
        vim.schedule(function()
            exec_autocmd({ hlsearch = last_hlsearch })
        end)
    end
    vim.defer_fn(check_hlsearch, interval)
end

vim.defer_fn(check_hlsearch, interval)

vim.on_key(function(key)
    if api.nvim_get_mode().mode == "n" and key:match("[nN&*]") then
        exec_autocmd({ key = key })
    end
end)

api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineChanged", "CmdlineLeave" }, {
    group = api.nvim_create_augroup("NeominimapSearch", {}),
    callback = function()
        if require("neominimap.util").is_search_mode() then
            exec_autocmd({ pattern = fn.getcmdline() })
        end
    end,
})

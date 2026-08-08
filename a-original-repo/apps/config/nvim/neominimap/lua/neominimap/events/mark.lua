local api, fn = vim.api, vim.fn

local function exec_autocmd(data)
    api.nvim_exec_autocmds("User", {
        pattern = "Mark",
        data = data,
        group = "Neominimap",
    })
end

local function mark_set_keymap(key, m)
    local mkey = key .. m
    if fn.maparg(mkey) == "" then
        vim.keymap.set({ "n", "x" }, mkey, function()
            exec_autocmd({ key = mkey })
            return mkey
        end, { unique = true, expr = true })
    end
end

return function(key)
    for code = string.byte("A"), string.byte("Z") do
        mark_set_keymap(key, string.char(code))
    end

    for code = string.byte("a"), string.byte("z") do
        mark_set_keymap(key, string.char(code))
    end

    local group = api.nvim_create_augroup("NeominimapMark", {})
    for _, cmd in ipairs({ "k", "mar", "delm" }) do
        api.nvim_create_autocmd("CmdlineLeave", {
            group = group,
            callback = function()
                if fn.getcmdtype() == ":" and vim.startswith(fn.getcmdline(), cmd) then
                    exec_autocmd({ cmd = cmd })
                end
            end,
        })
    end
end

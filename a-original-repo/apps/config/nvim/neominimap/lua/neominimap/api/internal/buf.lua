local enable = function(bufnr)
    local var = require("neominimap.variables")
    var.b[bufnr].enabled = true
    require("neominimap.buffer").get_buf_apis().enable(bufnr)
end

local disable = function(bufnr)
    local var = require("neominimap.variables")
    var.b[bufnr].enabled = false
    require("neominimap.buffer").get_buf_apis().disable(bufnr)
end

local function enabled(bufnr)
    local var = require("neominimap.variables")
    if not bufnr then
        bufnr = vim.api.nvim_get_current_buf()
    end
    return var.b[bufnr].enabled
end

local toggle = function(bufnr)
    local var = require("neominimap.variables")
    if var.b[bufnr].enabled then
        disable(bufnr)
    else
        enable(bufnr)
    end
end

local refresh = function(bufnr)
    require("neominimap.buffer").get_buf_apis().refresh(bufnr)
end

local validate_buf_list = function(buf_list)
    local is_valid, err = require("neominimap.api.util").validate_list_of_integers(buf_list)
    if not is_valid then
        return false, err
    end
    for _, bufno in ipairs(buf_list) do
        if not vim.api.nvim_buf_is_valid(bufno) then
            return false, string.format("Buffer %d is not valid.", bufno)
        end
    end
    return true
end

local wrap_buf_function = function(func)
    return function(buf_list)
        if buf_list == nil then
            buf_list = { vim.api.nvim_get_current_buf() }
        elseif type(buf_list) ~= "table" then
            buf_list = { buf_list }
        end
        local is_valid, err = validate_buf_list(buf_list)
        if not is_valid then
            error(err)
        end
        vim.tbl_map(func, buf_list)
    end
end

return {
    enable = wrap_buf_function(enable),
    disable = wrap_buf_function(disable),
    enabled = enabled,
    toggle = wrap_buf_function(toggle),
    refresh = wrap_buf_function(refresh),
}

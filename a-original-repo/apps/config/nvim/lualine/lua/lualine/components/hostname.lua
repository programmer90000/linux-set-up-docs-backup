local modules = require("lualine_require").lazy_require {
    utils = "lualine.utils.utils",
}

local function hostname()
    return modules.utils.stl_escape(vim.loop.os_gethostname())
end

return hostname

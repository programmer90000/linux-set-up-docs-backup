local M = {}

M.sections = {
    lualine_a = {
        function()
            return "OverseerList"
        end,
    },
}

M.filetypes = { "OverseerList" }

return M

local nerdtree = require("lualine.extensions.nerdtree")

local M = {}

M.sections = vim.deepcopy(nerdtree.sections)

M.filetypes = { "NvimTree" }

return M

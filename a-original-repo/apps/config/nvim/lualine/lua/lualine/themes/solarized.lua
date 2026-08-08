local background = vim.opt.background:get()

return require("lualine.themes.solarized_" .. background)

local background = vim.opt.background:get()
local style = vim.g.ayucolor or ((background == "dark") and vim.g.ayuprefermirage and "mirage" or background)

return require("lualine.themes.ayu_" .. style)

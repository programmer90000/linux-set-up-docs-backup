-- General Options
vim.autoindent = true
vim.autoread = true
vim.autowrite = false
vim.autowriteall = false
vim.backspace = "indent,eol,start"
vim.backup = false
vim.breakindent = true
vim.o.confirm = true
vim.o.copyindent = true
vim.o.equalalways = false
vim.o.errorbells = true
vim.opt.expandtab = true
vim.o.fileignorecase = true
vim.o.hlsearch = true
vim.o.infercase = false
vim.o.laststatus = 2
vim.o.mouse = "a"
vim.o.mousefocus = false
vim.o.mousehide = false
vim.o.mousemodel = "popup_setpos"
vim.opt.number = true
vim.o.preserveindent = true
vim.opt.relativenumber = false
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.tabstop = 4
vim.o.mousescroll = "ver:3,hor:0"
vim.o.mousetime = 500
vim.o.numberwidth = 1
vim.o.preserveindent = false
vim.o.pumblend = 30
vim.o.ruler = true
vim.o.rulerformat = "Line:%l  Col:%c  Virtual:%v  Char:0x%B  Pos:%o  %p%%  %L lines"
vim.o.shell = "/bin/bash"
vim.o.shelltemp = true
vim.o.shiftround = true
vim.o.shiftwidth = 4
vim.o.showbreak = "↪ "
vim.o.showcmd = false
vim.o.showmatch = true
vim.o.showmode = true
vim.o.showtabline = 2
vim.o.smarttab = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.statusline = ""
vim.o.tabline = ""
vim.o.undofile = true
vim.o.undolevels = 1000
vim.o.undoreload = 10000
vim.o.visualbell = true
vim.o.warn = true
vim.o.wrap = true
vim.o.write = true
vim.o.writeany = false
vim.o.writebackup = true
vim.o.writedelay = 0
vim.o.pumheight = 10
vim.o.pumwidth = 40
vim.o.winblend = 50
vim.o.winfixheight = false
vim.o.winfixwidth = false
vim.o.winfixbuf = false
vim.o.winheight = 1
vim.o.winhighlight = ""
vim.o.winminwidth = 10
vim.o.winwidth = 20
vim.o.wrapscan = true
vim.o.indentkeys = ""
vim.o.quoteescape = ""
vim.o.report = 0
vim.o.scrolloff = 8
vim.o.shellcmdflag = ""
vim.o.shellquote = ""
vim.o.tabpagemax = 30
vim.o.undodir = os.getenv("HOME") .. "/.local/share/nvim/undo"
vim.o.winbar = ""

vim.cmd("colorscheme colour-scheme")

-- Load Plugin Configs
local config_path = vim.fn.stdpath("config") .. "/config/"

dofile(config_path .. "dependencies.lua")
dofile(config_path .. "autopairs.lua")
dofile(config_path .. "comment.lua")
dofile(config_path .. "ibl.lua")
dofile(config_path .. "lualine.lua")
dofile(config_path .. "mason.lua")
dofile(config_path .. "neo-tree.lua")
dofile(config_path .. "neominimap.lua")
dofile(config_path .. "nvim-surround.lua")
dofile(config_path .. "nvim-treesitter.lua")
dofile(config_path .. "quickui.lua")
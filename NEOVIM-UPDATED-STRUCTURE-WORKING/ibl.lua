vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/plugins/indent-blankline/"))

require("ibl").setup()
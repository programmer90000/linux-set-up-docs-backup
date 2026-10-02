vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/plugins/autopairs/"))

require("nvim-autopairs").setup()
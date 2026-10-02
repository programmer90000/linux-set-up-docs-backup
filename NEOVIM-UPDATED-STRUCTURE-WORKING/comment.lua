vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/plugins/comment/"))

require("Comment").setup()
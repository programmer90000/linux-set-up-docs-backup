vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/plugins/nvim-treesitter/"))

require("nvim-treesitter").setup {
    install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "nvim-treesitter"),
}
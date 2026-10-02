vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/plugins/mason/"))

require("mason").setup {
    install_root_dir = vim.fn.stdpath("data") .. "/mason",
    PATH = "prepend",
    log_level = vim.log.levels.INFO,
    max_concurrent_installers = 2,

    ui = {
        check_outdated_packages_on_open = false,
        border = nil,
        backdrop = 60,
        width = 0.8,
        height = 0.9,
        icons = {
            package_installed = "✅",
            package_pending = "⏳",
            package_uninstalled = "❌",
        },

        keymaps = {},
    },
}
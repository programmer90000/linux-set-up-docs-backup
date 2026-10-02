vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/plugins/quickui/"))

require("quickui").setup({
    keymap = "<F10>",
    border = "single",
    menus = {
        {
            name = "&File",
            items = {
                { name = "&New",   cmd = ":enew<CR>", key = "<C-n>" },
                { name = "&Open",  cmd = ":e ",       key = "<C-o>" },
                { name = "&Save",  cmd = ":w<CR>",    key = "<C-s>" },
                { name = "separator" },
                { name = "&Quit",  cmd = ":qa<CR>",   key = "<C-q>" },
            },
        },
        {
            name = "&Edit",
            items = {
                { name = "&Undo",  cmd = "u",      key = "<C-z>" },
                { name = "&Redo",  cmd = "<C-r>",  key = "<C-y>" },
                { name = "&Copy",  cmd = '"+y',    key = "<C-c>" },
                { name = "&Paste", cmd = '"+p',    key = "<C-v>" },
            },
        },
        {
            name = "&Select",
            items = {
                { name = "&Select All", cmd = "ggVG", key = "<C-a>" },
            },
        },
    },
})
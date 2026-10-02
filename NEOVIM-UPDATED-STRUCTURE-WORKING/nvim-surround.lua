vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/plugins/nvim-surround/"))

require("nvim-surround").setup {
    keymaps = {},
    surrounds = {
        ["("] = {
            add = { "( ", " )" },
            find = function()
                return require("nvim-surround.config").get_selection { motion = "a(" }
            end,
            delete = "^(. ?)().-( ?.)()$",
        },
        [")"] = {
            add = { "(", ")" },
            find = function()
                return require("nvim-surround.config").get_selection { motion = "a)" }
            end,
            delete = "^(.)().-(.)()$",
        },
        ["{"] = {
            add = { "{ ", " }" },
            find = function()
                return require("nvim-surround.config").get_selection { motion = "a{" }
            end,
            delete = "^(. ?)().-( ?.)()$",
        },
        ["}"] = {
            add = { "{", "}" },
            find = function()
                return require("nvim-surround.config").get_selection { motion = "a}" }
            end,
            delete = "^(.)().-(.)()$",
        },
        ["["] = {
            add = { "[ ", " ]" },
            find = function()
                return require("nvim-surround.config").get_selection { motion = "a[" }
            end,
            delete = "^(. ?)().-( ?.)()$",
        },
        ["]"] = {
            add = { "[", "]" },
            find = function()
                return require("nvim-surround.config").get_selection { motion = "a]" }
            end,
            delete = "^(.)().-(.)()$",
        },
        ["'"] = {
            add = { "'", "'" },
            find = function()
                return require("nvim-surround.config").get_selection { motion = "a'" }
            end,
            delete = "^(.)().-(.)()$",
        },
        ['"'] = {
            add = { '"', '"' },
            find = function()
                return require("nvim-surround.config").get_selection { motion = 'a"' }
            end,
            delete = "^(.)().-(.)()$",
        },
        ["`"] = {
            add = { "`", "`" },
            find = function()
                return require("nvim-surround.config").get_selection { motion = "a`" }
            end,
            delete = "^(.)().-(.)()$",
        },
    },
    highlight = {
        duration = 1,
    },
    move_cursor = "begin",
    indent_lines = function(start, stop)
        local b = vim.bo
        if start < stop and (b.equalprg ~= "" or b.indentexpr ~= "" or b.cindent or b.smartindent or b.lisp) then
            vim.cmd(string.format("silent normal! %dG=%dG", start, stop))
            require("nvim-surround.cache").set_callback("")
        end
    end,
}
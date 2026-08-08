vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/mason/"))
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/lualine/"))
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/nvim-surround/"))
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/nvim-treesitter/"))
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/plenary/"))
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/nui/"))
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/nvim-web-devicons/"))
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/neo-tree/"))
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/indent-blankline/"))
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/comment/"))
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/neominimap/"))
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/autopairs/"))
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/quickui/"))

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

require("lualine").setup {
    options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        always_show_tabline = true,
        globalstatus = vim.go.laststatus == 3,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
            refresh_time = 16,
            events = {
                "WinEnter",
                "BufEnter",
                "BufWritePost",
                "SessionLoadPost",
                "FileChangedShellPost",
                "VimResized",
                "Filetype",
                "CursorMoved",
                "CursorMovedI",
                "ModeChanged",
            },
        },
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {},
}

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

require("nvim-treesitter").setup {
    install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "nvim-treesitter"),
}

require("neo-tree").setup {
    sources = {
        "filesystem",
        "buffers",
    },
    add_blank_line_at_top = false,
    auto_clean_after_session_restore = false,
    clipboard = {
        sync = "none",
    },
    close_if_last_window = false,
    default_source = "filesystem",
    enable_diagnostics = true,
    enable_modified_markers = true,
    enable_opened_markers = true,
    enable_refresh_on_write = true,
    enable_cursor_hijack = true,
    hide_root_node = false,
    retain_hidden_root_indent = false,
    keep_altfile = false,
    log_level = vim.log.levels.INFO,
    log_to_file = false,
    open_files_in_last_window = true,
    open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "edgy" },
    open_files_using_relative_paths = false,
    popup_border_style = "single",
    resize_timer_interval = 500,
    sort_case_insensitive = false,
    sort_function = nil,
    use_popups_for_input = true,
    use_default_mappings = true,
    source_selector = {
        winbar = false,
        statusline = false,
        show_scrolled_off_parent_node = false,
        sources = {
            { source = "filesystem" },
            { source = "buffers" },
        },
        content_layout = "start",
        tabs_layout = "equal",
        truncation_character = "...",
        tabs_min_width = nil,
        tabs_max_width = nil,
        padding = 0,
        separator = { left = "▏", right = "▕" },
        separator_active = nil,
        show_separator_on_edge = false,
        highlight_tab = "NeoTreeTabInactive",
        highlight_tab_active = "NeoTreeTabActive",
        highlight_background = "NeoTreeTabInactive",
        highlight_separator = "NeoTreeTabSeparatorInactive",
        highlight_separator_active = "NeoTreeTabSeparatorActive",
    },
    default_component_configs = {
        container = {
            enable_character_fade = true,
            width = "100%",
            right_padding = 0,
        },
        indent = {
            indent_size = 4,
            padding = 1,
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "└",
            highlight = "NeoTreeIndentMarker",
            with_expanders = nil,
            expander_collapsed = "",
            expander_expanded = "",
            expander_highlight = "NeoTreeExpander",
        },
        icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "󰉖",
            folder_empty_open = "󰷏",
            use_filtered_colors = true,
            default = "*",
            highlight = "NeoTreeFileIcon",
            provider = function(icon, node, state)
                if node.type == "file" or node.type == "terminal" then
                    local success, web_devicons = pcall(require, "nvim-web-devicons")
                    local name = node.type == "terminal" and "terminal" or node.name
                    if success then
                        local devicon, hl = web_devicons.get_icon(name)
                        icon.text = devicon or icon.text
                        icon.highlight = hl or icon.highlight
                    end
                end
            end,
        },
        modified = {
            symbol = "[+] ",
            highlight = "NeoTreeModified",
        },
        name = {
            trailing_slash = true,
            highlight_opened_files = true,
            use_filtered_colors = true,
            use_git_status_colors = false,
            highlight = "NeoTreeFileName",
        },
        file_size = {
            enabled = false,
            width = 12,
            required_width = 64,
        },
        type = {
            enabled = false,
            width = 10,
            required_width = 110,
        },
        last_modified = {
            enabled = false,
            width = 20,
            required_width = 88,
            format = "%Y-%m-%d %I:%M %p",
        },
        created = {
            enabled = false,
            width = 20,
            required_width = 120,
            format = "%Y-%m-%d %I:%M %p",
        },
        symlink_target = {
            enabled = false,
            target_display = "force_absolute",
            text_format = " ➛ %s",
        },
    },
    renderers = {
        directory = {
            { "indent" },
            { "icon" },
            { "current_filter" },
            {
                "container",
                content = {
                    { "name", zindex = 10 },
                    {
                        "symlink_target",
                        zindex = 10,
                        highlight = "NeoTreeSymbolicLinkTarget",
                    },
                    { "clipboard", zindex = 10 },
                    { "diagnostics", errors_only = true, zindex = 20, align = "right", hide_when_expanded = true },
                    { "git_status", zindex = 10, align = "right", hide_when_expanded = true },
                    { "file_size", zindex = 10, align = "right" },
                    { "type", zindex = 10, align = "right" },
                    { "last_modified", zindex = 10, align = "right" },
                    { "created", zindex = 10, align = "right" },
                },
            },
        },
        file = {
            { "indent" },
            { "icon" },
            {
                "container",
                content = {
                    {
                        "name",
                        zindex = 10,
                    },
                    {
                        "symlink_target",
                        zindex = 10,
                        highlight = "NeoTreeSymbolicLinkTarget",
                    },
                    { "clipboard", zindex = 10 },
                    { "bufnr", zindex = 10 },
                    { "modified", zindex = 20, align = "right" },
                    { "diagnostics", zindex = 20, align = "right" },
                    { "git_status", zindex = 10, align = "right" },
                    { "file_size", zindex = 10, align = "right" },
                    { "type", zindex = 10, align = "right" },
                    { "last_modified", zindex = 10, align = "right" },
                    { "created", zindex = 10, align = "right" },
                },
            },
        },
        message = {
            { "indent", with_markers = false },
            { "name", highlight = "NeoTreeMessage" },
        },
        terminal = {
            { "indent" },
            { "icon" },
            { "name" },
            { "bufnr" },
        },
    },
    nesting_rules = {},
    commands = {},
    window = {
        position = "left",
        width = 40,
        height = 15,
        auto_expand_width = false,
        popup = {
            size = {
                height = "80%",
                width = "50%",
            },
            position = "50%",
            title = function(state)
                return "Neo-tree " .. state.name:gsub("^%l", string.upper)
            end,
        },
        insert_as = "child",
        mapping_options = {
            noremap = true,
            nowait = true,
        },
        mappings = {},
    },
    filesystem = {
        window = {
            mappings = {},
            fuzzy_finder_mappings = {},
        },
        async_directory_scan = "auto",
        scan_mode = "shallow",
        bind_to_cwd = true,
        cwd_target = {
            sidebar = "tab",
            current = "window",
        },
        check_gitignore_in_search = true,
        filtered_items = {
            visible = false,
            force_visible_in_empty_folder = false,
            children_inherit_highlights = true,
            show_hidden_count = true,
            hide_dotfiles = true,
            hide_gitignored = false,
            hide_ignored = true,
            ignore_files = {},
            hide_hidden = true,
            hide_by_name = {},
            hide_by_pattern = {},
            always_show = {},
            always_show_by_pattern = {},
            never_show = {},
            never_show_by_pattern = {},
        },
        find_by_full_path_words = false,
        group_empty_dirs = false,
        search_limit = 50,
        follow_current_file = {
            enabled = false,
            leave_dirs_open = false,
        },
        hijack_netrw_behavior = "open_default",
        use_libuv_file_watcher = false,
    },
    buffers = {
        bind_to_cwd = true,
        follow_current_file = {
            enabled = true,
            leave_dirs_open = false,
        },
        group_empty_dirs = true,
        show_unloaded = false,
        terminals_first = false,
        window = {
            mappings = {},
        },
    },
    git_status = {
        window = {},
    },
    document_symbols = {
        follow_cursor = false,
        client_filters = "first",
        renderers = {
            root = {
                { "indent" },
                { "icon", default = "C" },
                { "name", zindex = 10 },
            },
            symbol = {
                { "indent", with_expanders = true },
                { "kind_icon", default = "?" },
                {
                    "container",
                    content = {
                        { "name", zindex = 10 },
                        { "kind_name", zindex = 20, align = "right" },
                    },
                },
            },
        },
        window = {
            mappings = {},
        },
        custom_kinds = {},
        kinds = {
            Unknown = { icon = "?", hl = "" },
            Root = { icon = "", hl = "NeoTreeRootName" },
            File = { icon = "󰈙", hl = "Tag" },
            Module = { icon = "", hl = "Exception" },
            Namespace = { icon = "󰌗", hl = "Include" },
            Package = { icon = "󰏖", hl = "Label" },
            Class = { icon = "󰌗", hl = "Include" },
            Method = { icon = "", hl = "Function" },
            Property = { icon = "󰆧", hl = "@property" },
            Field = { icon = "", hl = "@field" },
            Constructor = { icon = "", hl = "@constructor" },
            Enum = { icon = "󰒻", hl = "@number" },
            Interface = { icon = "", hl = "Type" },
            Function = { icon = "󰊕", hl = "Function" },
            Variable = { icon = "", hl = "@variable" },
            Constant = { icon = "", hl = "Constant" },
            String = { icon = "󰀬", hl = "String" },
            Number = { icon = "󰎠", hl = "Number" },
            Boolean = { icon = "", hl = "Boolean" },
            Array = { icon = "󰅪", hl = "Type" },
            Object = { icon = "󰅩", hl = "Type" },
            Key = { icon = "󰌋", hl = "" },
            Null = { icon = "", hl = "Constant" },
            EnumMember = { icon = "", hl = "Number" },
            Struct = { icon = "󰌗", hl = "Type" },
            Event = { icon = "", hl = "Constant" },
            Operator = { icon = "󰆕", hl = "Operator" },
            TypeParameter = { icon = "󰊄", hl = "Type" },
        },
    },
}

require("ibl").setup()
require('Comment').setup()
require("nvim-autopairs").setup()

vim.g.neominimap = {
  auto_enable = true,
  click = {
    enabled = true,
    auto_switch_focus = true,
  },
}

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

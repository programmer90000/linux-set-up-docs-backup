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
vim.o.mousehide = true
vim.o.mousemodel = "popup_setpos"
vim.opt.number = true
vim.o.preserveindent = true
vim.opt.relativenumber = false
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.tabstop = 4
vim.cmd('colorscheme colour-scheme')
vim.cmd('luafile ~/.config/nvim/menu/menu.lua')
vim.opt.runtimepath:append("~/.config/nvim/mason")
require("mason").setup()
require("lualine").setup()
require("mason").setup()
require('nvim-treesitter.config').setup({
  ensure_installed = { "lua", "python", "c" },
  highlight = { enable = true },
})
require("neo-tree").setup({
  close_if_last_window = false, -- STILL NEED TO CHECK THIS OPTION
  popup_border_style = "rounded", -- STILL NEED TO CHECK THIS OPTION
  enable_git_status = true, -- STILL NEED TO CHECK THIS OPTION
  enable_diagnostics = true, -- STILL NEED TO CHECK THIS OPTION
  
  default_component_configs = {
    container = {
      enable_character_fade = true -- STILL NEED TO CHECK THIS OPTION
    },
    indent = {
      indent_size = 2, -- STILL NEED TO CHECK THIS OPTION
      padding = 1, -- STILL NEED TO CHECK THIS OPTION
      with_markers = true, -- STILL NEED TO CHECK THIS OPTION
      indent_marker = "│", -- STILL NEED TO CHECK THIS OPTION
      last_indent_marker = "└", -- STILL NEED TO CHECK THIS OPTION
      highlight = "NeoTreeIndentMarker", -- STILL NEED TO CHECK THIS OPTION
    },
    icon = {
      folder_closed = "", -- STILL NEED TO CHECK THIS OPTION
      folder_open = "", -- STILL NEED TO CHECK THIS OPTION
      folder_empty = "󰜌", -- STILL NEED TO CHECK THIS OPTION
      default = "*", -- STILL NEED TO CHECK THIS OPTION
    },
    modified = {
      symbol = "[+]", -- STILL NEED TO CHECK THIS OPTION
      highlight = "NeoTreeModified", -- STILL NEED TO CHECK THIS OPTION
    },
    name = {
      trailing_slash = false, -- STILL NEED TO CHECK THIS OPTION
      use_git_status_colors = true, -- STILL NEED TO CHECK THIS OPTION
    },
    git_status = {
      symbols = {
        added     = "✚", -- STILL NEED TO CHECK THIS OPTION
        modified  = "", -- STILL NEED TO CHECK THIS OPTION
        deleted   = "✖", -- STILL NEED TO CHECK THIS OPTION
        renamed   = "", -- STILL NEED TO CHECK THIS OPTION
        unstaged  = "󰄱", -- STILL NEED TO CHECK THIS OPTION
        staged    = "", -- STILL NEED TO CHECK THIS OPTION
        unmerged  = "", -- STILL NEED TO CHECK THIS OPTION
        untracked = "", -- STILL NEED TO CHECK THIS OPTION
        dirty     = "󰄱", -- STILL NEED TO CHECK THIS OPTION
        ignored   = "◌", -- STILL NEED TO CHECK THIS OPTION
        clean     = "✔︎", -- STILL NEED TO CHECK THIS OPTION
        none      = "", -- STILL NEED TO CHECK THIS OPTION
        unknown   = "?", -- STILL NEED TO CHECK THIS OPTION
      },
    },
  },
  
  window = {
    position = "left", -- STILL NEED TO CHECK THIS OPTION
    width = 40, -- STILL NEED TO CHECK THIS OPTION
    mapping_options = {
      noremap = true, -- STILL NEED TO CHECK THIS OPTION
      nowait = true, -- STILL NEED TO CHECK THIS OPTION
    },
    mappings = {
      ["<space>"] = "none", -- Disable space key -- STILL NEED TO CHECK THIS OPTION
      ["<2-LeftMouse>"] = "open", -- STILL NEED TO CHECK THIS OPTION
      ["<cr>"] = "open", -- STILL NEED TO CHECK THIS OPTION
      ["S"] = "open_split", -- STILL NEED TO CHECK THIS OPTION
      ["s"] = "open_vsplit", -- STILL NEED TO CHECK THIS OPTION
      ["C"] = "close_node", -- STILL NEED TO CHECK THIS OPTION
      ["<bs>"] = "navigate_up", -- STILL NEED TO CHECK THIS OPTION
      ["."] = "set_root", -- STILL NEED TO CHECK THIS OPTION
      ["H"] = "toggle_hidden", -- STILL NEED TO CHECK THIS OPTION
      ["R"] = "refresh", -- STILL NEED TO CHECK THIS OPTION
      ["/"] = "filter_on_submit", -- STILL NEED TO CHECK THIS OPTION
      ["<c-x>"] = "clear_filter", -- STILL NEED TO CHECK THIS OPTION
      ["a"] = "add", -- STILL NEED TO CHECK THIS OPTION
      ["d"] = "delete", -- STILL NEED TO CHECK THIS OPTION
      ["r"] = "rename", -- STILL NEED TO CHECK THIS OPTION
      ["y"] = "copy_to_clipboard", -- STILL NEED TO CHECK THIS OPTION
      ["x"] = "cut_to_clipboard", -- STILL NEED TO CHECK THIS OPTION
      ["p"] = "paste_from_clipboard", -- STILL NEED TO CHECK THIS OPTION
      ["c"] = "copy", -- takes text input for destination -- STILL NEED TO CHECK THIS OPTION
      ["m"] = "move", -- takes text input for destination -- STILL NEED TO CHECK THIS OPTION
      ["q"] = "close_window", -- STILL NEED TO CHECK THIS OPTION
    },
  },
  
  nesting_rules = {}, -- STILL NEED TO CHECK THIS OPTION
  
  filesystem = {
    filtered_items = {
      visible = false, -- when true, they will just be displayed differently -- STILL NEED TO CHECK THIS OPTION
      hide_dotfiles = true, -- STILL NEED TO CHECK THIS OPTION
      hide_gitignored = true, -- STILL NEED TO CHECK THIS OPTION
      hide_hidden = true, -- only works on Windows for hidden files/directories -- STILL NEED TO CHECK THIS OPTION
      hide_by_name = {
        "node_modules", -- STILL NEED TO CHECK THIS OPTION
        ".git", -- STILL NEED TO CHECK THIS OPTION
        "__pycache__", -- STILL NEED TO CHECK THIS OPTION
      },
      hide_by_pattern = { -- uses glob style patterns
        --"*.meta", -- STILL NEED TO CHECK THIS OPTION
        --"*/src/*/tsconfig.json", -- STILL NEED TO CHECK THIS OPTION
      },
      always_show = { -- remains visible even if other settings would normally hide it
        ".gitignore", -- STILL NEED TO CHECK THIS OPTION
      },
      never_show = { -- remains hidden even if visible is toggled to true
        ".DS_Store", -- STILL NEED TO CHECK THIS OPTION
        "thumbs.db", -- STILL NEED TO CHECK THIS OPTION
      },
    },
    follow_current_file = {
      enabled = true, -- This will find and focus the file in the active buffer every time -- STILL NEED TO CHECK THIS OPTION
    },
    group_empty_dirs = false, -- when true, empty folders will be grouped together -- STILL NEED TO CHECK THIS OPTION
    hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree -- STILL NEED TO CHECK THIS OPTION
    use_libuv_file_watcher = false, -- This will use the OS level file watchers -- STILL NEED TO CHECK THIS OPTION
  },
  
  buffers = {
    follow_current_file = {
      enabled = true, -- This will find and focus the file in the active buffer every time -- STILL NEED TO CHECK THIS OPTION
    },
    group_empty_dirs = false, -- when true, empty folders will be grouped together -- STILL NEED TO CHECK THIS OPTION
    show_unloaded = true, -- STILL NEED TO CHECK THIS OPTION
    window = {
      mappings = {
        ["bd"] = "buffer_delete", -- STILL NEED TO CHECK THIS OPTION
        ["<bs>"] = "navigate_up", -- STILL NEED TO CHECK THIS OPTION
        ["."] = "set_root", -- STILL NEED TO CHECK THIS OPTION
      },
    },
  },
  
  git_status = {
    window = {
      position = "float", -- STILL NEED TO CHECK THIS OPTION
      mappings = {
        ["A"]  = "git_add_all", -- STILL NEED TO CHECK THIS OPTION
        ["gu"] = "git_unstage_file", -- STILL NEED TO CHECK THIS OPTION
        ["ga"] = "git_add_file", -- STILL NEED TO CHECK THIS OPTION
        ["gr"] = "git_revert_file", -- STILL NEED TO CHECK THIS OPTION
        ["gc"] = "git_commit", -- STILL NEED TO CHECK THIS OPTION
        ["gp"] = "git_push", -- STILL NEED TO CHECK THIS OPTION
        ["gg"] = "git_commit_and_push", -- STILL NEED TO CHECK THIS OPTION
      },
    },
  },
})

vim.o.indentkeys = "NEED-TO-SET-THIS"
vim.o.mousescroll = "NEED-TOSET-THIS"
vim.o.mousetime = 500 -- NEED TO SET THIS
vim.o.numberwidth = 4 -- NEED TO SET THIS
vim.o.preserveindent = true -- NEED TO SET THIS
vim.o.pumblend = 10 -- NEED TO SET THIS
vim.o.pumborder = true -- NEED TO SET THIS
vim.o.pumheight = 10 -- NEED TO SET THIS
vim.o.pumwidth = 40 -- NEED TO SET THIS
vim.o.pummaxwidth = 80 -- NEED TO SET THIS
vim.o.quoteescape = "NEED-TO-SET-THIS"
vim.o.report = 2 -- NEED TO SET THIS
vim.o.ruler = true -- NEED TO SET THIS
vim.o.rulerformat = "%l:%c" -- NEED TO SET THIS
vim.o.scrollback = 10000 -- NEED TO SET THIS
vim.o.scrolloff = 8 -- NEED TO SET THIS
vim.o.shell = "/bin/bash" -- NEED TO SET THIS
vim.o.shellcmdflag = "-c" -- NEED TO SET THIS
vim.o.shellquote = "" -- NEED TO SET THIS
vim.o.shellslash = false -- NEED TO SET THIS
vim.o.shelltemp = true -- NEED TO SET THIS
vim.o.shiftround = true -- NEED TO SET THIS
vim.o.shiftwidth = 4 -- NEED TO SET THIS
vim.o.showbreak = "↪ " -- NEED TO SET THIS
vim.o.showcmd = true -- NEED TO SET THIS
vim.o.showmatch = true -- NEED TO SET THIS
vim.o.showmode = false -- NEED TO SET THIS
vim.o.showtabline = 2 -- NEED TO SET THIS
vim.o.smarttab = true -- NEED TO SET THIS
vim.o.splitright = true -- NEED TO SET THIS
vim.o.splitbelow = true -- NEED TO SET THIS
vim.o.statusline = "" -- NEED TO SET THIS
vim.o.tabline = "" -- NEED TO SET THIS
vim.o.tabpagemax = 10 -- NEED TO SET THIS
vim.o.undodir = os.getenv("HOME") .. "/.local/share/nvim/undo" -- NEED TO SET THIS
vim.o.undofile = true -- NEED TO SET THIS
vim.o.undolevels = 1000 -- NEED TO SET THIS
vim.o.undoreload = 10000 -- NEED TO SET THIS
vim.o.visualbell = false -- NEED TO SET THIS
vim.o.warn = true -- NEED TO SET THIS
vim.o.winbar = "" -- NEED TO SET THIS
vim.o.winblend = 0 -- NEED TO SET THIS
vim.o.winborder = "single" -- NEED TO SET THIS
vim.o.winfixheight = false -- NEED TO SET THIS
vim.o.winfixwidth = false -- NEED TO SET THIS
vim.o.winfixbuf = false -- NEED TO SET THIS
vim.o.winheight = 10 -- NEED TO SET THIS
vim.o.winhighlight = "" -- NEED TO SET THIS
vim.o.winminheight = 3 -- NEED TO SET THIS
vim.o.winminwidth = 10 -- NEED TO SET THIS
vim.o.winwidth = 20 -- NEED TO SET THIS
vim.o.wrap = true -- NEED TO SET THIS
vim.o.wrapscan = true -- NEED TO SET THIS
vim.o.write = true -- NEED TO SET THIS
vim.o.writeany = false -- NEED TO SET THIS
vim.o.writebackup = true -- NEED TO SET THIS
vim.o.writedelay = 0 -- NEED TO SET THIS
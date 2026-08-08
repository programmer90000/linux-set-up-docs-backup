vim.cmd("highlight clear")
vim.cmd("set background=dark")

local colors = {
    bg = "#0a0a0a",
    fg = "#e8e8e8",
    statusline_bg = "#141414",
    statusline_nc_bg = "#080808",
    line_number_fg = "#666666",
    cursor_line_bg = "#111111",
    visual_bg = "#222222",
    cursor_bg = "#e8e8e8",
    float_bg = "#080808",
    border_fg = "#333333",
    pmenu_bg = "#141414",
    pmenu_fg = "#b0b0b0",
    pmenu_sel_bg = "#2a2a2a",
    pmenu_sel_fg = "#ffffff",
    search_bg = "#444444",
    search_fg = "#ffffff",
    incsearch_bg = "#888888",
    incsearch_fg = "#000000",
    folded_bg = "#0d0d0d",
    folded_fg = "#808080",
    tabline_bg = "#141414",
    tabline_fg = "#a0a0a0",
    tabline_fill_bg = "#050505",
    win_separator_fg = "#222222",
    mode_msg_fg = "#cccccc",
    more_msg_fg = "#808080",
    nontext_fg = "#404040",
    specialkey_fg = "#505050",
    accent_yellow = "#d0d0d0",
    accent_blue = "#aaaaaa",
    accent_cyan = "#b8b8b8",
    accent_green = "#c0c0c0",
    accent_magenta = "#c8c8c8",
    accent_red = "#b0b0b0",
    accent_orange = "#bbbbbb",
    accent_purple = "#c4c4c4",
}

-- Core UI
vim.api.nvim_set_hl(0, "Normal", { bg = colors.bg, fg = colors.fg })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = colors.float_bg })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = colors.float_bg, fg = colors.border_fg })

-- Status line
vim.api.nvim_set_hl(0, "StatusLine", { bg = colors.statusline_bg, fg = colors.fg })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = colors.statusline_nc_bg, fg = colors.line_number_fg })

-- Line numbers
vim.api.nvim_set_hl(0, "LineNr", { fg = colors.line_number_fg })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = colors.accent_yellow, bold = true })

-- Cursor and selection
vim.api.nvim_set_hl(0, "Cursor", { bg = colors.cursor_bg })
vim.api.nvim_set_hl(0, "CursorLine", { bg = colors.cursor_line_bg })
vim.api.nvim_set_hl(0, "Visual", { bg = colors.visual_bg })

-- Sidebar and separators
vim.api.nvim_set_hl(0, "VertSplit", { fg = colors.win_separator_fg, bg = colors.tabline_fill_bg })
vim.api.nvim_set_hl(0, "WinSeparator", { fg = colors.win_separator_fg })

-- Menu and completion
vim.api.nvim_set_hl(0, "Pmenu", { bg = colors.pmenu_bg, fg = colors.pmenu_fg })
vim.api.nvim_set_hl(0, "PmenuSel", { bg = colors.pmenu_sel_bg, fg = colors.pmenu_sel_fg })
vim.api.nvim_set_hl(0, "PmenuThumb", { bg = colors.accent_blue })

-- Search highlighting
vim.api.nvim_set_hl(0, "Search", { bg = colors.search_bg, fg = colors.search_fg })
vim.api.nvim_set_hl(0, "IncSearch", { bg = colors.incsearch_bg, fg = colors.incsearch_fg })

-- Command line and messages
vim.api.nvim_set_hl(0, "MsgArea", { fg = colors.fg })
vim.api.nvim_set_hl(0, "ModeMsg", { fg = colors.mode_msg_fg })
vim.api.nvim_set_hl(0, "MoreMsg", { fg = colors.more_msg_fg })

-- Gutter and signs
vim.api.nvim_set_hl(0, "SignColumn", { bg = colors.bg })
vim.api.nvim_set_hl(0, "FoldColumn", { fg = colors.line_number_fg })

-- Folding
vim.api.nvim_set_hl(0, "Folded", { bg = colors.folded_bg, fg = colors.folded_fg })

-- Tab line
vim.api.nvim_set_hl(0, "TabLine", { bg = colors.tabline_bg, fg = colors.tabline_fg })
vim.api.nvim_set_hl(0, "TabLineSel", { bg = colors.accent_blue, fg = colors.pmenu_sel_fg })
vim.api.nvim_set_hl(0, "TabLineFill", { bg = colors.tabline_fill_bg })

-- Terminal
vim.api.nvim_set_hl(0, "Terminal", { bg = colors.bg, fg = colors.fg })

-- Special elements
vim.api.nvim_set_hl(0, "NonText", { fg = colors.nontext_fg })
vim.api.nvim_set_hl(0, "SpecialKey", { fg = colors.specialkey_fg })
vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = colors.nontext_fg })

-- Diagnostics
vim.api.nvim_set_hl(0, "DiagnosticError", { fg = colors.accent_red })
vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = colors.accent_orange })
vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = colors.accent_blue })
vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = colors.accent_cyan })

-- Syntax groups
vim.api.nvim_set_hl(0, "@comment", { fg = colors.line_number_fg, italic = true })
vim.api.nvim_set_hl(0, "@string", { fg = colors.accent_green })
vim.api.nvim_set_hl(0, "@constant", { fg = colors.accent_blue })
vim.api.nvim_set_hl(0, "@number", { fg = colors.accent_orange })
vim.api.nvim_set_hl(0, "@boolean", { fg = colors.accent_orange })
vim.api.nvim_set_hl(0, "@function", { fg = colors.accent_blue })
vim.api.nvim_set_hl(0, "@keyword", { fg = colors.accent_magenta, bold = true })
vim.api.nvim_set_hl(0, "@type", { fg = colors.accent_yellow })
vim.api.nvim_set_hl(0, "@variable", { fg = colors.fg })
vim.api.nvim_set_hl(0, "@operator", { fg = colors.accent_magenta })

-- Git signs
vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = colors.accent_green })
vim.api.nvim_set_hl(0, "GitSignsChange", { fg = colors.accent_blue })
vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = colors.accent_red })

-- Terminal colors
vim.g.terminal_color_0 = colors.bg
vim.g.terminal_color_8 = colors.statusline_bg
vim.g.terminal_color_1 = colors.accent_red
vim.g.terminal_color_9 = colors.accent_red
vim.g.terminal_color_2 = colors.accent_green
vim.g.terminal_color_10 = colors.accent_green
vim.g.terminal_color_3 = colors.accent_yellow
vim.g.terminal_color_11 = colors.accent_yellow
vim.g.terminal_color_4 = colors.accent_blue
vim.g.terminal_color_12 = colors.accent_blue
vim.g.terminal_color_5 = colors.accent_magenta
vim.g.terminal_color_13 = colors.accent_magenta
vim.g.terminal_color_6 = colors.accent_cyan
vim.g.terminal_color_14 = colors.accent_cyan
vim.g.terminal_color_7 = colors.fg
vim.g.terminal_color_15 = colors.fg

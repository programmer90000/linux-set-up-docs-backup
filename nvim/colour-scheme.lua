-- Custom dark color scheme
vim.cmd('highlight clear')
vim.cmd('set background=dark')

local colors = {
    bg = "#000000",
    fg = "#e0e0e0",
    statusline_bg = "#1a1a1a",
    statusline_nc_bg = "#0a0a0a",
    line_number_fg = "#606060",
    cursor_line_bg = "#111111",
    visual_bg = "#2a2a2a",
    cursor_bg = "#e0e0e0",
    float_bg = "#0a0a0a",
    border_fg = "#333333",
    pmenu_bg = "#111111",
    pmenu_fg = "#b0b0b0",
    pmenu_sel_bg = "#2a2a2a",
    pmenu_sel_fg = "#ffffff",
    search_bg = "#333333",
    search_fg = "#ffffff",
    incsearch_bg = "#ffaa00",
    incsearch_fg = "#000000",
    folded_bg = "#0d0d0d",
    folded_fg = "#808080",
    tabline_bg = "#111111",
    tabline_fg = "#a0a0a0",
    tabline_fill_bg = "#050505",
    win_separator_fg = "#222222",
    mode_msg_fg = "#ffaa00",
    more_msg_fg = "#808080",
    nontext_fg = "#404040",
    specialkey_fg = "#505050",
    accent_yellow = "#ffcc00",
    accent_blue = "#6699ff",
    accent_cyan = "#66cccc",
    accent_green = "#99cc66",
    accent_magenta = "#cc99cc",
    accent_red = "#ff6666"
}

-- Clear existing highlights
vim.api.nvim_command('highlight clear')

-- Core UI
vim.api.nvim_set_hl(0, 'Normal', { bg = colors.bg, fg = colors.fg })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = colors.float_bg })
vim.api.nvim_set_hl(0, 'FloatBorder', { bg = colors.float_bg, fg = colors.border_fg })

-- Status line
vim.api.nvim_set_hl(0, 'StatusLine', { bg = colors.statusline_bg, fg = colors.fg })
vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = colors.statusline_nc_bg, fg = colors.line_number_fg })

-- Line numbers
vim.api.nvim_set_hl(0, 'LineNr', { fg = colors.line_number_fg })
vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = colors.accent_yellow, bold = true })

-- Cursor and selection
vim.api.nvim_set_hl(0, 'Cursor', { bg = colors.cursor_bg })
vim.api.nvim_set_hl(0, 'CursorLine', { bg = colors.cursor_line_bg })
vim.api.nvim_set_hl(0, 'Visual', { bg = colors.visual_bg })

-- Sidebar and separators
vim.api.nvim_set_hl(0, 'VertSplit', { fg = colors.win_separator_fg, bg = colors.tabline_fill_bg })
vim.api.nvim_set_hl(0, 'WinSeparator', { fg = colors.win_separator_fg })

-- Menu and completion
vim.api.nvim_set_hl(0, 'Pmenu', { bg = colors.pmenu_bg, fg = colors.pmenu_fg })
vim.api.nvim_set_hl(0, 'PmenuSel', { bg = colors.pmenu_sel_bg, fg = colors.pmenu_sel_fg })

-- Search highlighting
vim.api.nvim_set_hl(0, 'Search', { bg = colors.search_bg, fg = colors.search_fg })
vim.api.nvim_set_hl(0, 'IncSearch', { bg = colors.incsearch_bg, fg = colors.incsearch_fg })

-- Command line and messages
vim.api.nvim_set_hl(0, 'MsgArea', { fg = colors.fg })
vim.api.nvim_set_hl(0, 'ModeMsg', { fg = colors.mode_msg_fg })
vim.api.nvim_set_hl(0, 'MoreMsg', { fg = colors.more_msg_fg })

-- Gutter and signs
vim.api.nvim_set_hl(0, 'SignColumn', { bg = colors.bg })
vim.api.nvim_set_hl(0, 'FoldColumn', { fg = colors.line_number_fg })

-- Folding
vim.api.nvim_set_hl(0, 'Folded', { bg = colors.folded_bg, fg = colors.folded_fg })

-- Tab line
vim.api.nvim_set_hl(0, 'TabLine', { bg = colors.tabline_bg, fg = colors.tabline_fg })
vim.api.nvim_set_hl(0, 'TabLineSel', { bg = colors.accent_blue, fg = colors.pmenu_sel_fg })
vim.api.nvim_set_hl(0, 'TabLineFill', { bg = colors.tabline_fill_bg })

-- Terminal
vim.api.nvim_set_hl(0, 'Terminal', { bg = colors.bg, fg = colors.fg })

-- Special elements
vim.api.nvim_set_hl(0, 'NonText', { fg = colors.nontext_fg })
vim.api.nvim_set_hl(0, 'SpecialKey', { fg = colors.specialkey_fg })

-- Set terminal colors (for terminal buffers in Neovim)
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
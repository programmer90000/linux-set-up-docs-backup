local M = {}

local config = require("neominimap.config")

local braille_chars = ""
    .. "⠀⠁⠂⠃⠄⠅⠆⠇⡀⡁⡂⡃⡄⡅⡆⡇⠈⠉⠊⠋⠌⠍⠎⠏⡈⡉⡊⡋⡌⡍⡎⡏"
    .. "⠐⠑⠒⠓⠔⠕⠖⠗⡐⡑⡒⡓⡔⡕⡖⡗⠘⠙⠚⠛⠜⠝⠞⠟⡘⡙⡚⡛⡜⡝⡞⡟"
    .. "⠠⠡⠢⠣⠤⠥⠦⠧⡠⡡⡢⡣⡤⡥⡦⡧⠨⠩⠪⠫⠬⠭⠮⠯⡨⡩⡪⡫⡬⡭⡮⡯"
    .. "⠰⠱⠲⠳⠴⠵⠶⠷⡰⡱⡲⡳⡴⡵⡶⡷⠸⠹⠺⠻⠼⠽⠾⠿⡸⡹⡺⡻⡼⡽⡾⡿"
    .. "⢀⢁⢂⢃⢄⢅⢆⢇⣀⣁⣂⣃⣄⣅⣆⣇⢈⢉⢊⢋⢌⢍⢎⢏⣈⣉⣊⣋⣌⣍⣎⣏"
    .. "⢐⢑⢒⢓⢔⢕⢖⢗⣐⣑⣒⣓⣔⣕⣖⣗⢘⢙⢚⢛⢜⢝⢞⢟⣘⣙⣚⣛⣜⣝⣞⣟"
    .. "⢠⢡⢢⢣⢤⢥⢦⢧⣠⣡⣢⣣⣤⣥⣦⣧⢨⢩⢪⢫⢬⢭⢮⢯⣨⣩⣪⣫⣬⣭⣮⣯"
    .. "⢰⢱⢲⢳⢴⢵⢶⢷⣰⣱⣲⣳⣴⣵⣶⣷⢸⢹⢺⢻⢼⢽⢾⢿⣸⣹⣺⣻⣼⣽⣾⣿"

local braille_codes = vim.fn.str2list(braille_chars)

M.bitmap_to_code = function(bitmap)
    return braille_codes[bitmap + 1]
end

M.bitmap_to_char = function(bitmap)
    return vim.fn.list2str({ M.bitmap_to_code(bitmap) })
end

M.map_point_to_flag = function(y, x)
    local relRow = bit.band(y, 3)
    local relCol = bit.band(x, 1)
    return bit.lshift(1, bit.bor(relRow, relCol * 4))
end

M.map_point_to_mcodepoint = function(y, x)
    return bit.rshift(y, 2) + 1, bit.rshift(x, 1) + 1
end

M.map_point_to_codepoint = function(y, x)
    return y * config.y_multiplier + 1, x * config.x_multiplier + 1
end

M.mcodepoint_to_map_point = function(mrow, mcol)
    return bit.lshift(mrow - 1, 2), bit.lshift(mcol - 1, 1)
end

M.codepoint_to_map_point = function(row, col)
    return math.floor((row - 1) / config.y_multiplier), math.floor((col - 1) / config.x_multiplier)
end

M.codepoint_to_mcodepoint = function(row, col)
    local y, x = M.codepoint_to_map_point(row, col)
    return M.map_point_to_mcodepoint(y, x)
end

M.mcodepoint_to_codepoint = function(mrow, mcol)
    local y, x = M.mcodepoint_to_map_point(mrow, mcol)
    return M.map_point_to_codepoint(y, x)
end

return M

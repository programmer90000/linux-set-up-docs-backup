local function location()
    local line = vim.fn.line(".")
    local col = vim.fn.charcol(".")
    return string.format("%3d:%-2d", line, col)
end

return location

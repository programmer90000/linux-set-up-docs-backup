local M = {}

M.get_all_folds = function(bufnr)
    local folds = {}
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    vim.api.nvim_buf_call(bufnr, function()
        local line = 1
        while line <= line_count and vim.fn.foldlevel(line) do
            local foldend = vim.fn.foldclosedend(line)
            if foldend ~= -1 then
                folds[#folds + 1] = { start = line, end_ = foldend }
                line = foldend + 1
            else
                line = line + 1
            end
        end
    end)

    return folds
end

M.is_line_folded = function(bufnr, line)
    local folded = false

    -- Run the function in the context of the buffer with bufnr
    vim.api.nvim_buf_call(bufnr, function()
        folded = vim.fn.foldclosed(line) ~= -1
    end)

    return folded
end

M.filter_folds = function(folds, lines)
    local filtered_lines = {}
    local index = 1
    for line_num, line in ipairs(lines) do
        while index <= #folds and folds[index].end_ < line_num do
            index = index + 1
        end
        if index > #folds or folds[index].start >= line_num then
            filtered_lines[#filtered_lines + 1] = line
        end
    end
    return filtered_lines
end

M.subtract_fold_lines = function(folds, lineNr)
    local acc = 0
    for _, f in ipairs(folds) do
        if lineNr <= f.start then
            break
        elseif lineNr <= f.end_ then
            return f.start - acc, true
        else
            acc = acc + f.end_ - f.start
        end
    end
    return lineNr - acc, false
end

M.get_visible_range = function(folds, start_row, end_row)
    local v_start, hidden_start = M.subtract_fold_lines(folds, start_row)
    local v_end, _ = M.subtract_fold_lines(folds, end_row)

    if hidden_start then
        v_start = v_start + 1
    end

    return v_start, v_end
end

M.add_fold_lines = function(folds, lineNr)
    for _, f in ipairs(folds) do
        if lineNr <= f.start then
            break
        else
            lineNr = lineNr + f.end_ - f.start
        end
    end
    return lineNr
end

M.get_cached_folds = function(bufnr)
    local var = require("neominimap.variables")
    return var.b[bufnr].cached_folds
end

M.cache_folds = function(bufnr)
    local var = require("neominimap.variables")
    var.b[bufnr].cached_folds = M.get_all_folds(bufnr)
end

return M

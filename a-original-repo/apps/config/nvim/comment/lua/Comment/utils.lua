local F = require('Comment.ft')
local A = vim.api

local U = {}

U.cmode = {
    toggle = 0,
    comment = 1,
    uncomment = 2,
}

U.ctype = {
    linewise = 1,
    blockwise = 2,
}

U.cmotion = {
    line = 1,
    char = 2,
    block = 3,
    v = 4,
    V = 5,
}

function U.is_empty(iter)
    return #iter == 0
end

function U.get_pad(flag)
    return flag and ' ' or ''
end

function U.get_padpat(flag)
    return flag and '%s?' or ''
end

function U.is_fn(fn, ...)
    if type(fn) == 'function' then
        return fn(...)
    end
    return fn
end

function U.ignore(ln, pat)
    return pat and string.find(ln, pat) ~= nil
end

function U.get_region(opmode)
    if not opmode then
        local row = unpack(A.nvim_win_get_cursor(0))
        return { srow = row, scol = 0, erow = row, ecol = 0 }
    end
    
    local marks = string.match(opmode, '[vV]') and { '<', '>' } or { '[', ']' }
    local sln, eln = A.nvim_buf_get_mark(0, marks[1]), A.nvim_buf_get_mark(0, marks[2])
    
    return { srow = sln[1], scol = sln[2], erow = eln[1], ecol = eln[2] }
end

function U.get_count_lines(count)
    local srow = unpack(A.nvim_win_get_cursor(0))
    local erow = (srow + count) - 1
    local lines = A.nvim_buf_get_lines(0, srow - 1, erow, false)
    
    return lines, { srow = srow, scol = 0, erow = erow, ecol = 0 }
end

function U.get_lines(range)
    -- If start and end is same, then just return the current line
    if range.srow == range.erow then
        return { A.nvim_get_current_line() }
    end
    
    return A.nvim_buf_get_lines(0, range.srow - 1, range.erow, false)
end

function U.unwrap_cstr(cstr)
    local left, right = string.match(cstr, '(.*)%%s(.*)')
    
    assert(
        (left or right),
        { msg = string.format('Invalid commentstring for %s! Read `:h commentstring` for help.', vim.bo.filetype) }
    )
    
    return vim.trim(left), vim.trim(right)
end

function U.parse_cstr(cfg, ctx)
    -- 1. We ask `pre_hook` for a commentstring
    local inbuilt = U.is_fn(cfg.pre_hook, ctx)
        -- 2. Calculate w/ the help of treesitter
        or F.calculate(ctx)
    
    assert(inbuilt or (ctx.ctype ~= U.ctype.blockwise), {
        msg = vim.bo.filetype .. " doesn't support block comments!",
    })
    
    -- 3. Last resort to use native commentstring
    return U.unwrap_cstr(inbuilt or vim.bo.commentstring)
end

function U.commenter(left, right, padding, scol, ecol, tabbed)
    local pad = U.get_pad(padding)
    local ll = U.is_empty(left) and left or (left .. pad)
    local rr = U.is_empty(right) and right or (pad .. right)
    local empty = string.rep(tabbed and '\t' or ' ', scol or 0) .. left .. right
    local is_lw = scol and not ecol
    
    return function(line)
        ------------------
        -- for linewise --
        ------------------
        if is_lw then
            if U.is_empty(line) then
                return empty
            end
            -- line == 0 -> start from 0 col
            if scol == 0 then
                return (ll .. line .. rr)
            end
            local first = string.sub(line --[[@as string]], 0, scol)
            local last = string.sub(line --[[@as string]], scol + 1, -1)
            return first .. ll .. last .. rr
        end
        
        -------------------
        -- for blockwise --
        -------------------
        if type(line) == 'table' then
            local first, last = line[1], line[#line]
            -- If both columns are given then we can assume it's a partial block
            if scol and ecol then
                local sfirst = string.sub(first, 0, scol)
                local slast = string.sub(first, scol + 1, -1)
                local efirst = string.sub(last, 0, ecol + 1)
                local elast = string.sub(last, ecol + 2, -1)
                line[1] = sfirst .. ll .. slast
                line[#line] = efirst .. rr .. elast
            else
                line[1] = U.is_empty(first) and left or string.gsub(first, '^(%s*)', '%1' .. vim.pesc(ll))
                line[#line] = U.is_empty(last) and right or (last .. rr)
            end
            return line
        end
        
        --------------------------------
        -- for current-line blockwise --
        --------------------------------
        if ecol > #line then
            return ll .. line .. rr
        end
        local first = string.sub(line, 0, scol)
        local mid = string.sub(line, scol + 1, ecol + 1)
        local last = string.sub(line, ecol + 2, -1)
        return first .. ll .. mid .. rr .. last
    end
end

function U.uncommenter(left, right, padding, scol, ecol)
    local pp, plen = U.get_padpat(padding), padding and 1 or 0
    local left_len, right_len = #left + plen, #right + plen
    local ll = U.is_empty(left) and left or vim.pesc(left) .. pp
    local rr = U.is_empty(right) and right or pp .. vim.pesc(right)
    local is_lw = not (scol and scol)
    local pattern = is_lw and '^(%s*)' .. ll .. '(.-)' .. rr .. '$' or ''
    
    return function(line)
        -------------------
        -- for blockwise --
        -------------------
        if type(line) == 'table' then
            local first, last = line[1], line[#line]
            -- If both columns are given then we can assume it's a partial block
            if scol and ecol then
                local sfirst = string.sub(first, 0, scol)
                local slast = string.sub(first, scol + left_len + 1, -1)
                local efirst = string.sub(last, 0, ecol - right_len + 1)
                local elast = string.sub(last, ecol + 2, -1)
                line[1] = sfirst .. slast
                line[#line] = efirst .. elast
            else
                line[1] = string.gsub(first, '^(%s*)' .. ll, '%1')
                line[#line] = string.gsub(last, rr .. '$', '')
            end
            return line
        end
        
        ------------------
        -- for linewise --
        ------------------
        if is_lw then
            local a, b, c = string.match(line, pattern)
            -- When user tries to uncomment when there is nothing to uncomment. See #221
            assert(a and b, { msg = 'Nothing to uncomment!' })
            -- If there is nothing after LHS then just return ''
            -- bcz the line previously (before comment) was empty
            return U.is_empty(b) and b or a .. b .. (c or '')
        end
        
        --------------------------------
        -- for current-line blockwise --
        --------------------------------
        if ecol > #line then
            return string.sub(line, scol + left_len + 1, #line - right_len)
        end
        local first = string.sub(line, 0, scol)
        local mid = string.sub(line, scol + left_len + 1, ecol - right_len + 1)
        local last = string.sub(line, ecol + 2, -1)
        return first .. mid .. last
    end
end

function U.is_commented(left, right, padding, scol, ecol)
    local pp = U.get_padpat(padding)
    local ll = U.is_empty(left) and left or '^%s*' .. vim.pesc(left) .. pp
    local rr = U.is_empty(right) and right or pp .. vim.pesc(right) .. '$'
    local pattern = ll .. '.-' .. rr
    local is_full = scol == nil or ecol == nil
    
    return function(line)
        -------------------
        -- for blockwise --
        -------------------
        if type(line) == 'table' then
            local first, last = line[1], line[#line]
            if is_full then
                return (string.find(first, ll) and string.find(last, rr)) ~= nil
            end
            return (string.find(string.sub(first, scol + 1, -1), ll) and string.find(string.sub(last, 0, ecol + 1), rr))
                ~= nil
        end
        
        ------------------
        -- for linewise --
        ------------------
        if is_full then
            return string.find(line, pattern) ~= nil
        end
        
        --------------------------------
        -- for current-line blockwise --
        --------------------------------
        return string.find(string.sub(line, scol + 1, (ecol > #line and #line or ecol + 1)), pattern) ~= nil
    end
end

function U.catch(fn, ...)
    xpcall(fn, function(err)
        vim.notify(string.format('[Comment.nvim] %s', err.msg), vim.log.levels.WARN)
    end, ...)
end

return U

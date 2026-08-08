local U = require('Comment.utils')
local Config = require('Comment.config')
local A = vim.api

local Op = {}

function Op.opfunc(motion, cfg, cmode, ctype)
    local range = U.get_region(motion)
    local cmotion = motion == nil and U.cmotion.line or U.cmotion[motion]
    
    -- If we are doing char or visual motion on the same line then we would probably want block comment instead of line comment
    local is_partial = cmotion == U.cmotion.char or cmotion == U.cmotion.v
    local is_blockx = is_partial and range.srow == range.erow
    
    local lines = U.get_lines(range)
    
    -- sometimes there might be a case when there are no lines like, executing a text object returns nothing
    if U.is_empty(lines) then
        return
    end
    
    local ctx = {
        cmode = cmode,
        cmotion = cmotion,
        ctype = is_blockx and U.ctype.blockwise or ctype,
        range = range,
    }
    
    local lcs, rcs = U.parse_cstr(cfg, ctx)
    
    local params = {
        cfg = cfg,
        lines = lines,
        lcs = lcs,
        rcs = rcs,
        cmode = cmode,
        range = range,
    }
    
    if motion ~= nil and (is_blockx or ctype == U.ctype.blockwise) then
        ctx.cmode = Op.blockwise(params, is_partial)
    else
        ctx.cmode = Op.linewise(params)
    end
    
    if cfg.sticky and Config.position and cmotion ~= U.cmotion.v and cmotion ~= U.cmotion.V then
        A.nvim_win_set_cursor(0, Config.position)
        Config.position = nil
    end
    
    U.is_fn(cfg.post_hook, ctx)
end

function Op.count(count, cfg, cmode, ctype)
    local lines, range = U.get_count_lines(count)
    
    local ctx = {
        cmode = cmode,
        cmotion = U.cmotion.line,
        ctype = ctype,
        range = range,
    }
    local lcs, rcs = U.parse_cstr(cfg, ctx)
    
    local params = {
        cfg = cfg,
        cmode = ctx.cmode,
        lines = lines,
        lcs = lcs,
        rcs = rcs,
        range = range,
    }
    
    if ctype == U.ctype.blockwise then
        ctx.cmode = Op.blockwise(params)
    else
        ctx.cmode = Op.linewise(params)
    end
    
    U.is_fn(cfg.post_hook, ctx)
end

function Op.linewise(param)
    local pattern = U.is_fn(param.cfg.ignore)
    local padding = U.is_fn(param.cfg.padding)
    local check_comment = U.is_commented(param.lcs, param.rcs, padding)

    -- While commenting a region, there could be lines being both commented and non-commented, So, if any line is uncommented then we should comment the whole block or vise-versa
    local cmode = U.cmode.uncomment

    ---When commenting multiple line, it is to be expected that indentation should be preserved so, When looping over multiple lines we need to store the indentation of the mininum length (except empty line) which will be used to semantically comment rest of the lines
    local min_indent, tabbed = -1, false
    
    -- If the given cmode is uncomment then we actually don't want to compute the cmode or min_indent
    if param.cmode ~= U.cmode.uncomment then
        for _, line in ipairs(param.lines) do
            if not U.ignore(line, pattern) then
                if cmode == U.cmode.uncomment and param.cmode == U.cmode.toggle and (not check_comment(line)) then
                    cmode = U.cmode.comment
                end
                
                if not U.is_empty(line) and param.cmode ~= U.cmode.uncomment then
                    local _, len = string.find(line, '^%s*')
                    if min_indent == -1 or min_indent > len then
                        min_indent, tabbed = len, string.find(line, '^\t') ~= nil
                    end
                end
            end
        end
    end
    
    -- If the comment mode given is not toggle than force that mode
    if param.cmode ~= U.cmode.toggle then
        cmode = param.cmode
    end
    
    if cmode == U.cmode.uncomment then
        local uncomment = U.uncommenter(param.lcs, param.rcs, padding)
        for i, line in ipairs(param.lines) do
            if not U.ignore(line, pattern) then
                param.lines[i] = uncomment(line)
            end
        end
    else
        local comment = U.commenter(param.lcs, param.rcs, padding, min_indent, nil, tabbed)
        for i, line in ipairs(param.lines) do
            if not U.ignore(line, pattern) then
                param.lines[i] = comment(line)
            end
        end
    end
    
    A.nvim_buf_set_lines(0, param.range.srow - 1, param.range.erow, false, param.lines)
    
    return cmode
end

function Op.blockwise(param, partial)
    local is_x = #param.lines == 1 -- current-line blockwise
    local lines = is_x and param.lines[1] or param.lines
    
    local padding = U.is_fn(param.cfg.padding)
    
    local scol, ecol = nil, nil
    if is_x or partial then
        scol, ecol = param.range.scol, param.range.ecol
    end
    
    -- If given mode is toggle then determine whether to comment or not
    local cmode = param.cmode
    if cmode == U.cmode.toggle then
        local is_cmt = U.is_commented(param.lcs, param.rcs, padding, scol, ecol)(lines)
        cmode = is_cmt and U.cmode.uncomment or U.cmode.comment
    end
    
    if cmode == U.cmode.uncomment then
        lines = U.uncommenter(param.lcs, param.rcs, padding, scol, ecol)(lines)
    else
        lines = U.commenter(param.lcs, param.rcs, padding, scol, ecol)(lines)
    end
    
    if is_x then
        A.nvim_set_current_line(lines)
    else
        A.nvim_buf_set_lines(0, param.range.srow - 1, param.range.erow, false, lines)
    end
    
    return cmode
end

return Op

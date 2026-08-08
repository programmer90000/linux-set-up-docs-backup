local C = {}

function C.setup(config)
    local cfg = require('Comment.config'):set(config):get()
    
    if cfg.mappings then
        local api = require('Comment.api')
        local vvar = vim.api.nvim_get_vvar
        local K = vim.keymap.set
        
        -- Basic Mappings
        if cfg.mappings.basic then
            -- NORMAL mode mappings
            K('n', cfg.opleader.line, '<Plug>(comment_toggle_linewise)', { desc = 'Comment toggle linewise' })
            K('n', cfg.opleader.block, '<Plug>(comment_toggle_blockwise)', { desc = 'Comment toggle blockwise' })

            K('n', cfg.toggler.line, function()
                return vvar('count') == 0 and '<Plug>(comment_toggle_linewise_current)'
                    or '<Plug>(comment_toggle_linewise_count)'
            end, { expr = true, desc = 'Comment toggle current line' })
            K('n', cfg.toggler.block, function()
                return vvar('count') == 0 and '<Plug>(comment_toggle_blockwise_current)'
                    or '<Plug>(comment_toggle_blockwise_count)'
            end, { expr = true, desc = 'Comment toggle current block' })
            
            -- VISUAL mode mappings
            K(
                'x',
                cfg.opleader.line,
                '<Plug>(comment_toggle_linewise_visual)',
                { desc = 'Comment toggle linewise (visual)' }
            )
            K(
                'x',
                cfg.opleader.block,
                '<Plug>(comment_toggle_blockwise_visual)',
                { desc = 'Comment toggle blockwise (visual)' }
            )
        end
        
        -- Extra Mappings
        if cfg.mappings.extra then
            K('n', cfg.extra.below, api.insert.linewise.below, { desc = 'Comment insert below' })
            K('n', cfg.extra.above, api.insert.linewise.above, { desc = 'Comment insert above' })
            K('n', cfg.extra.eol, api.locked('insert.linewise.eol'), { desc = 'Comment insert end of line' })
        end
    end
    
    return cfg
end

return C

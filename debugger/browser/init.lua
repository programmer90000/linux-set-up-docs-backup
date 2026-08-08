local dap = require('dap')

local function get_js_debug_path()
    local home = os.getenv('HOME')
    return home .. '/.local/share/nvim/dap-adapters/vscode-js-debug/dist/src/dapDebugServer.js'
end

local debug_host = "localhost"  -- Use "::1" if connection fails

dap.adapters["pwa-msedge"] = {
    type = "server",
    host = debug_host,
    port = "${port}",
    executable = {
        command = "node",
        args = { get_js_debug_path(), "${port}" },
    },
}

local js_based_languages = { 
    "javascript", 
    "typescript", 
    "javascriptreact",
    "typescriptreact",
}

for _, language in ipairs(js_based_languages) do
    dap.configurations[language] = {
        {
            type = "pwa-msedge",
            request = "launch",
            name = "Launch Edge against localhost",
            url = "http://localhost:3000",
            webRoot = "${workspaceFolder}",
            sourceMaps = true,
            protocol = "inspector",
            skipFiles = { "<node_internals>/**" },
        },
        {
            type = "pwa-msedge",
            request = "attach",
            name = "Attach to Edge",
            url = "http://localhost:3000",
            webRoot = "${workspaceFolder}",
            port = 9222,
            sourceMaps = true,
        },
        {
            type = "pwa-msedge",
            request = "launch",
            name = "Launch Edge with custom URL",
            url = function()
                return vim.fn.input("URL: ", "http://localhost:3000")
            end,
            webRoot = "${workspaceFolder}",
            sourceMaps = true,
            protocol = "inspector",
        },
        {
            type = "pwa-msedge",
            request = "launch",
            name = "Launch Edge (InPrivate)",
            url = "http://localhost:3000",
            webRoot = "${workspaceFolder}",
            runtimeArgs = { "--inprivate" },
            sourceMaps = true,
        },
        {
            type = "pwa-msedge",
            request = "launch",
            name = "Launch Edge with specific user data dir",
            url = "http://localhost:3000",
            webRoot = "${workspaceFolder}",
            userDataDir = "${workspaceFolder}/.edge-profile",
            sourceMaps = true,
        },
    }
end

vim.keymap.set('n', '<F5>', function() dap.continue() end)
vim.keymap.set('n', '<F10>', function() dap.step_over() end)
vim.keymap.set('n', '<F11>', function() dap.step_into() end)
vim.keymap.set('n', '<F12>', function() dap.step_out() end)
vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end)
vim.keymap.set('n', '<leader>B', function() 
    dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) 
end)
vim.keymap.set('n', '<leader>dc', function() dap.continue() end)
vim.keymap.set('n', '<leader>dq', function() dap.terminate() end)
vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end)
vim.keymap.set('n', '<leader>dl', function() dap.run_last() end)

local ok_vtext, dap_vtext = pcall(require, "nvim-dap-virtual-text")
if ok_vtext then
    dap_vtext.setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = true,
        show_stop_reason = true,
        commented = false,
        virt_text_pos = 'eol',
        all_frames = true,
        virt_lines = false,
        virt_text_win_col = nil
    })
    
    -- Force update on stopped event (this is crucial!)
    dap.listeners.after.event_stopped["dap-virtual-text"] = function(session, body)
        -- Small delay to ensure variables are available
        vim.defer_fn(function()
        end, 50)
    end
    
end
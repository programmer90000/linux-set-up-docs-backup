local dap = require('dap')

local function get_js_debug_path()
    local home = os.getenv('HOME')
    return home .. '/.local/share/nvim/dap-adapters/vscode-js-debug/dist/src/dapDebugServer.js'
end

local debug_host = "localhost"  -- Use "::1" if connection fails

-- pwa-node adapter - for Node.js debugging
dap.adapters["pwa-node"] = {
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
}

for _, language in ipairs(js_based_languages) do
    dap.configurations[language] = {
        {
            type = "pwa-node",
            request = "launch",
            name = "Launch Node.js File",
            program = "${file}",
            cwd = "${workspaceFolder}",
            args = {},
            sourceMaps = true,
            skipFiles = { "<node_internals>/**" },
        },
        {
            type = "pwa-node",
            request = "attach",
            name = "Attach to Node.js Process",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**" },
        },
        {
            type = "pwa-node",
            request = "launch",
            name = "Launch with Arguments",
            program = "${file}",
            cwd = "${workspaceFolder}",
            args = function()
                local args_string = vim.fn.input("Arguments: ")
                return vim.split(args_string, " ")
            end,
            sourceMaps = true,
            skipFiles = { "<node_internals>/**" },
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

local ok_dapui, dapui = pcall(require, "dapui")
if ok_dapui then
    dapui.setup({
        icons = { expanded = "▾", collapsed = "▸" },
        mappings = {
            expand = { "<CR>", "<2-LeftMouse>" },
            open = "o",
            remove = "d",
            edit = "e",
        },
        layouts = {
            {
                elements = { 
                    { id = "scopes", size = 0.25 },
                    { id = "breakpoints", size = 0.25 },
                    { id = "stacks", size = 0.25 },
                    { id = "watches", size = 0.25 },
                },
                size = 40,
                position = "left",
            },
            {
                elements = { 
                    { id = "repl", size = 0.5 },
                    { id = "console", size = 0.5 },
                },
                size = 10,
                position = "bottom",
            },
        },
        floating = {
            max_height = 0.9,
            max_width = 0.5,
            border = "single",
        },
    })

    dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
    end

    vim.keymap.set('n', '<leader>du', function() dapui.toggle() end)
end

local ok_vtext, dap_vtext = pcall(require, "nvim-dap-virtual-text")
if ok_vtext then
    dap_vtext.setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = true,
        show_stop_reason = true,
        commented = false,
    })
end

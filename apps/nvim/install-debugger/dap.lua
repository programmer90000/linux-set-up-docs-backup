-- Prepend plugin paths to runtimepath
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/plugins/nvim-dap"))
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/plugins/nvim-dap-ui"))
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/plugins/nvim-nio"))

local dap = require("dap")
local dapui = require("dapui")

dapui.setup()

-- Path to js-debug inside your custom plugins directory
local js_debug_path = vim.fn.expand("~/.config/nvim/plugins/js-debug/src/vsDebugServer.js")

dap.adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = "node",
    args = {
      js_debug_path,
      "${port}",
    },
  },
}

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

dap.configurations.javascript = {
  {
    type = "pwa-node",
    request = "launch",
    name = "Launch Current File",
    program = "${file}",
    cwd = "${workspaceFolder}",
    sourceMaps = true,
  },
}

dap.configurations.typescript = dap.configurations.javascript

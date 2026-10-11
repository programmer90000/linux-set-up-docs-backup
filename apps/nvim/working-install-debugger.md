Run:
```
rm -rf ~/.config/nvim/
mkdir -p ~/.config/nvim/plugins/
mkdir -p ~/.config/nvim/config/
cp -r nvim-dap-ui ~/.config/nvim/plugins/
cp -r nvim-dap ~/.config/nvim/plugins/
cp -r nvim-nio ~/.config/nvim/plugins/
cd vscode-js-debug/
npm install --legacy-peer-deps
npx gulp dapDebugServer
mv dist out
cd ../
cp -r vscode-js-debug ~/.config/nvim/plugins/
```

Add this to config/dap.lua:
```
-- Add your manual plugin directories to runtimepath
vim.opt.rtp:append(vim.fn.stdpath("config") .. "/plugins/nvim-dap")
vim.opt.rtp:append(vim.fn.stdpath("config") .. "/plugins/nvim-dap-ui")
vim.opt.rtp:append(vim.fn.stdpath("config") .. "/plugins/nvim-nio")

require("dap").adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = "node",
    args = {
      vim.fn.stdpath("config") .. "/plugins/vscode-js-debug/dist/src/dapDebugServer.js",
      "${port}",
    },
  },
}

-- Add this configuration block:
require("dap").configurations.javascript = {
  {
    type = "pwa-node",
    request = "launch",
    name = "Launch current file",
    program = "${file}",
    cwd = "${workspaceFolder}",
  },
}

local dap, dapui = require("dap"), require("dapui")

dapui.setup()

-- Automatically open/close dapui on debug events
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end
```

Add this to init.lua:
```
local config_path = vim.fn.stdpath("config") .. "/config/"

dofile(config_path .. "dap.lua")
```

I have checked nvim-dap and nvim-dap-ui. They are ready to commit to the main repo
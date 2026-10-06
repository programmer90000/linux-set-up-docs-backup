PROMPT:
```
I am using Debian 13 without a DE. I have installed Neovim using ```sudo apt install neovim```. I have made the following config directory:
```
.config/
---- nvim/
-------- init.lua
------------ plugins/
---------------- lualine/
------------ config/
---------------- lualine.lua
```

.config/nvim/config/lualine.lua:
```
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/plugins/lualine/"))
require("lualine").setup {}
```

init.lua:
```
local config_path = vim.fn.stdpath("config") .. "/config/"
dofile(config_path .. "lualine.lua")
```

Using the same file structure and types of files, how can I clone and install nvim-dap and any required packages for debugging Node.js apps.

Give me a complete guide from start to finish. Assume I am installing this on a new Debian 13 computer with no configuration made yet
```

ANSWER:
```
To set up nvim-dap alongside js-debug-adapter (the official Microsoft debugger for Node.js) on a fresh Debian 13 installation using your exact file and directory structure, follow this guide.
1. System & Node.js Dependencies
First, install Git, Neovim, Node.js, and npm on Debian:
sudo apt update
sudo apt install -y git neovim nodejs npm

2. Clone the Neovim Plugins
In addition to nvim-dap, debugging Node.js requires:
* nvim-dap: The core Debug Adapter Protocol client for Neovim.
* vscode-js-debug: Microsoft's VS Code debug adapter for Node.js/JavaScript.
* nvim-dap-vscode-js: A Neovim extension that bridges nvim-dap with vscode-js-debug.
Run these commands to clone the plugins directly into your plugins/ directory:
# Navigate to your custom plugins directory
mkdir -p ~/.config/nvim/plugins
cd ~/.config/nvim/plugins

# Clone nvim-dap
git clone https://github.com/mfussenegger/nvim-dap.git dap

# Clone the JavaScript DAP helper
git clone https://github.com/mxsdev/nvim-dap-vscode-js.git dap-vscode-js

# Clone Microsoft's js-debug adapter (we clone tag v1.76.1 for a reliable build)
git clone --depth 1 --branch v1.76.1 https://github.com/microsoft/vscode-js-debug.git vscode-js-debug

3. Build the Node.js Debug Adapter
vscode-js-debug needs to be compiled using npm so Neovim can interact with its entry point (js-debug/src/dapDebugServer.js):
cd ~/.config/nvim/plugins/vscode-js-debug
npm install --legacy-peer-deps
npx gulp vsDebugServerBundle
mv dist build

4. Neovim Configuration Files
Set up the configuration files following your existing project structure.
File Structure Overview
.config/
└── nvim/
    ├── init.lua
    ├── plugins/
    │   ├── lualine/
    │   ├── dap/
    │   ├── dap-vscode-js/
    │   └── vscode-js-debug/
    └── config/
        ├── lualine.lua
        └── dap.lua

Create ~/.config/nvim/config/dap.lua
Create this file and add the runtime path additions, debugger adapter configuration, and language bindings:
-- 1. Prepend custom plugin paths to runtimepath
local plugins_path = vim.fn.expand("~/.config/nvim/plugins/")
vim.opt.rtp:prepend(plugins_path .. "dap")
vim.opt.rtp:prepend(plugins_path .. "dap-vscode-js")

-- 2. Configure nvim-dap-vscode-js
require("dap-vscode-js").setup({
  node_path = "node",
  debugger_path = plugins_path .. "vscode-js-debug",
  adapters = { 'pwa-node', 'pwa-chrome', 'node-terminal' },
})

-- 3. Configure DAP configurations for JavaScript & TypeScript
local dap = require("dap")

for _, language in ipairs({ "javascript", "typescript" }) do
  dap.configurations[language] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Current File (pwa-node)",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach to Process ID",
      processId = require('dap.utils').pick_process,
      cwd = "${workspaceFolder}",
    },
  }
end

-- 4. Keymaps for Debugging
vim.keymap.set("n", "<F5>", function() require("dap").continue() end, { desc = "DAP Continue" })
vim.keymap.set("n", "<F10>", function() require("dap").step_over() end, { desc = "DAP Step Over" })
vim.keymap.set("n", "<F11>", function() require("dap").step_into() end, { desc = "DAP Step Into" })
vim.keymap.set("n", "<F12>", function() require("dap").step_out() end, { desc = "DAP Step Out" })
vim.keymap.set("n", "<Leader>b", function() require("dap").toggle_breakpoint() end, { desc = "DAP Toggle Breakpoint" })
vim.keymap.set("n", "<Leader>B", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { desc = "DAP Set Conditional Breakpoint" })

Update ~/.config/nvim/init.lua
Update init.lua to load your new dap.lua config file alongside lualine.lua:
local config_path = vim.fn.stdpath("config") .. "/config/"

dofile(config_path .. "lualine.lua")
dofile(config_path .. "dap.lua")

5. Verification & Usage Test
* Open a JavaScript file in Neovim (e.g., app.js):
   const message = "Hello from Debugger";
console.log(message);

* Place your cursor on line 2 and press <Leader>b (space + b or your designated leader key) to set a breakpoint.
* Press <F5> to start debugging. Select Launch Current File (pwa-node).
* Execution will pause at your breakpoint, allowing you to step through with <F10> / <F11>.
```
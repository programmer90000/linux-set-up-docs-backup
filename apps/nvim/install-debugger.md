# How to install

Using Lazy.nvim, get the debuggers for every language. Commit them all to the backup repo. Inside the backup repo, add them all to the plugins directory. Make a new file inside the config repo titled `debuggers.lua`. Set it all up in the backup repo. After this, I can commit it to the main repo. Note that I still need to test if it works for browser based apps

# Install it using Lazy.nvim
Run:
```
mkdir -p ~/.config/nvim/lua/plugins/
```

~/.config/nvim/init.lua:
```
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
})
```

~/.config/nvim/lua/plugins/dap.lua:
```
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
            "${port}",
          },
        },
      }

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

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
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
  },
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "js-debug-adapter" },
        handlers = {},
      })
    end,
  },
}
```

Sync plugins: Open Neovim (nvim) and run :Lazy sync to download and install all plugins.

Install adapter: Run :Mason to verify that js-debug-adapter is installed successfully.

Test workflow: Create a test file, set a breakpoint with :DapToggleBreakpoint, and start debugging with :DapContinue. Run :DapContinue to continue debugging


# Install it manually

Copy:
```
~/.config/nvim/init.lua
~/.config/nvim/lua/plugins/dap.lua (though you can merge this directly into init.lua since you aren't using lazy)
```

Copy the installed plugins:
```
~/.local/share/nvim/lazy/
(You will need: nvim-dap, nvim-dap-ui, nvim-nio, mason.nvim, and mason-nvim-dap.nvim)
```


Copy the Debugger:
```
cp vscode-js-debug .config/nvim/plugins/
cd .config/nvim/plugins/vscode-js-debug/
npm install --legacy-peer-deps
npx gulp vsDebugServerBundle
mv dist out
```

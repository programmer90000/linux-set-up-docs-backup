### PROMPT:
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

Using the same file structure and types of files, how can I clone and install nvim ALE and any required packages for Node.js apps.

Give me a complete guide from start to finish. Assume I am installing this on a new Debian 13 computer with no configuration made yet

### ANSWER:
To get Lualine and ALE working for Node.js development, you need a few prerequisites installed on Debian first, followed by cloning the repositories into your plugins/ directory and requiring them in your config.
1. Install System Prerequisites
You need git to clone the plugins, nodejs and npm to run Node apps and linter/LSP servers, and curl or gcc for Neovim features.
Run this in your terminal:
sudo apt update
sudo apt install -y git neovim nodejs npm

To verify Node.js installed correctly, run node -v and npm -v.
2. Install Node.js Linters and LSP Tools
ALE acts as an asynchronous engine that hooks into external CLI tools for linting, fixing, and auto-completion. For Node.js (JavaScript/TypeScript), install ESLint and typescript-language-server globally via npm:
sudo npm install -g eslint typescript-language-server typescript

3. Set Up Directory Structure & Clone Plugins
Create your configuration and plugin folders, then clone lualine.nvim, nvim-web-devicons (required for lualine icons), and ale:
mkdir -p ~/.config/nvim/plugins
mkdir -p ~/.config/nvim/config

# Clone Lualine and its dependency
git clone https://github.com/nvim-lualine/lualine.nvim.nvim ~/.config/nvim/plugins/lualine
git clone https://github.com/kyazdani42/nvim-web-devicons ~/.config/nvim/plugins/nvim-web-devicons

# Clone ALE
git clone https://github.com/dense-analysis/ale.git ~/.config/nvim/plugins/ale

4. Create the Configuration Files
A. Configure Lualine (~/.config/nvim/config/lualine.lua)
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/plugins/nvim-web-devicons"))
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/plugins/lualine"))

require("lualine").setup {
  options = {
    theme = "auto",
    icons_enabled = true,
  }
}

How to verify: Open Neovim (nvim). If the statusline appears at the bottom without errors, Lualine loaded successfully.
B. Configure ALE (~/.config/nvim/config/ale.lua)
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/plugins/ale"))

-- Configure linters and fixers for Node.js / JavaScript / TypeScript
vim.g.ale_linters = {
  javascript = { "eslint", "tsserver" },
  typescript = { "eslint", "tsserver" },
}

vim.g.ale_fixers = {
  javascript = { "eslint" },
  typescript = { "eslint" },
}

-- Enable linting on file open/save and enable ALE LSP features
vim.g.ale_lint_on_save = 1
vim.g.ale_lint_on_enter = 1
vim.g.ale_disable_lsp = 0

How to verify: Open a JavaScript file (nvim test.js) with intentional syntax or lint errors. ALE will mark errors on the left sign column.
C. Main Entry Point (~/.config/nvim/init.lua)
local config_path = vim.fn.stdpath("config") .. "/config/"

dofile(config_path .. "lualine.lua")
dofile(config_path .. "ale.lua")
#!/bin/bash

echo "Installing Dependencies"
sudo apt update
sudo apt install -y nodejs npm git curl build-essential unzip

echo "Cloning nvim-dap"
mkdir -p ~/.local/share/nvim/site/pack/plugins/start/
cd ~/.local/share/nvim/site/pack/plugins/start/
git clone https://github.com/mfussenegger/nvim-dap.git
nvim --headless -c "helptags nvim-dap/doc" -c "q"

echo "Installing vscode-js-debug"
mkdir -p ~/.local/share/nvim/dap-adapters/
cd ~/.local/share/nvim/dap-adapters/
cp -r ~/linux-set-up-docs/debugger/nodejs/vscode-js-debug/ ~/.local/share/nvim/dap-adapters/
cd vscode-js-debug
npm install
npx gulp dapDebugServer
ls -la dist/src/dapDebugServer.js

echo "Cloning nvim-dap-ui"
cd ~/.local/share/nvim/site/pack/plugins/start/
git clone https://github.com/rcarriga/nvim-dap-ui.git
nvim --headless -c "helptags nvim-dap-ui/doc" -c "q"

echo "Cloning nvim-dap-virtual-text"
git clone https://github.com/theHamsta/nvim-dap-virtual-text.git

echo "Cloning nvim-nio"
git clone https://github.com/nvim-neotest/nvim-nio.git
nvim --headless -c "helptags nvim-nio/doc" -c "q"

echo "Copying init.lua to the ~/.config/nvim/ directory"
mkdir -p ~/.config/nvim/
cp ~/linux-set-up-docs/debugger/nodejs/init.lua ~/.config/nvim/init.lua

echo "1. Run the nodejs-create-file.sh file"
echo "2. Open the ~/nodejs.js file"
echo "3. Set a breakpoint by pressing <leader>b on each line"
echo "4. Press <F5> to start debugging"
echo "5. Select Launch Node.js File from the list"
echo "6. The debugger will stop at your breakpoint"
echo "7. Use <F10> to step over, <F11> to step into, <F12> to step out"
echo "8. View variables in the dap-ui sidebar (if installed) or open the REPL with <leader>dr"
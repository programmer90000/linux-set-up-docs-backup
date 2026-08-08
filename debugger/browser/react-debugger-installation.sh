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
cp -r ~/linux-set-up-docs/debugger/browser/vscode-js-debug/ ~/.local/share/nvim/dap-adapters/
cd vscode-js-debug
npm install
npx gulp dapDebugServer
ls -la dist/src/dapDebugServer.js

echo "Cloning nvim-dap-virtual-text"
git clone https://github.com/theHamsta/nvim-dap-virtual-text.git ~/.config/nvim/pack/plugins/start/

echo "Cloning nvim-nio"
git clone https://github.com/nvim-neotest/nvim-nio.git
nvim --headless -c "helptags nvim-nio/doc" -c "q"

echo "Copying init.lua to the ~/.config/nvim/ directory"
mkdir -p ~/.config/nvim/
cp ~/linux-set-up-docs/debugger/browser/init.lua ~/.config/nvim/init.lua

echo "1. Run the react-install-edge-and-create-app.sh file"
echo "2. Run: cd ~/react-app/"
echo "3. Run: nvim src/App.js"
echo "4. Set a breakpoint by pressing <leader>b on each line"
echo "5. Press <F5> to start debugging"
echo "6. Select Launch Edge Against Localhost from the list"
echo "7. The debugger will stop at your breakpoint"
echo "8. Use <F5> to move past the breakpoint"
echo "9. View variables in the dap-view sidebar or open the REPL with <leader>dr"
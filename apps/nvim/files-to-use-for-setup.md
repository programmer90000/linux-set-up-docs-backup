https://github.com/XXiaoA/atone.nvim/blob/main/lua/atone/config.lua

https://github.com/windwp/nvim-autopairs/blob/master/README.md - Use the Default Values section

https://github.com/numToStr/Comment.nvim/blob/master/README.md - Use the Configuration section

https://github.com/stevearc/conform.nvim/blob/master/README.md

https://github.com/sindrets/diffview.nvim/blob/main/README.md - Use the configuration section

https://github.com/lukas-reineke/indent-blankline.nvim/blob/master/lua/ibl/config.lua

https://github.com/nvim-lualine/lualine.nvim

https://github.com/mason-org/mason.nvim/blob/main/README.md - Use the Configuration section

https://github.com/nvim-tree/nvim-tree.lua/blob/master/doc/nvim-tree-lua.txt

https://github.com/Isrothy/neominimap.nvim/blob/main/README.md - Use the configuration section

https://github.com/mfussenegger/nvim-dap/blob/master/doc/dap.txt

https://github.com/kylechui/nvim-surround/blob/main/lua/nvim-surround/config.lua

https://github.com/nvim-tree/nvim-web-devicons/blob/master/README.md - Use the Setup section

https://github.com/lucc/nvimpager/blob/main/lua/nvimpager/options.lua

https://github.com/MeanderingProgrammer/render-markdown.nvim/blob/main/README.md - Use the setup section

https://github.com/nvim-treesitter/nvim-treesitter/blob/main/lua/nvim-treesitter/config.lua
```
vim.api.nvim_set_hl(0, '@function.javascript', { fg = '#ffcc00' })
```

Finding All Possible Things to Highlight

You can discover every capture name available for a language by looking at its query file directly.

· Official Query Files: For JavaScript, the canonical list is in the tree-sitter-javascript repository's queries/highlights.scm file. This file contains all the patterns, like (function_declaration name: (identifier) @function).
· Local Files: If you use nvim-treesitter, these files are installed on your system. You can find them in the plugin's queries/ directory.

The most common captures include @variable, @keyword, @string, @number, @type, and @comment. You can use the :Inspect command on any piece of code to see exactly which capture group is being applied to it.
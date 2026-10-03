Look at using this plugin to view output of commands in Neovim: [https://github.com/lucc/nvimpager](https://github.com/lucc/nvimpager)

1. Install this plugin to view MD files in Neovim: [https://github.com/MeanderingProgrammer/render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)

2. Look for a plugin to view terminal output in Neovim

3. Look for a way to copy the terminal output displayed in Neovim to the terminal

Display trailing whitespace and whitespace larger than 1 character. To do this, Add this to init.lua:
```
-- 1. Enable list mode and show trailing spaces as dots (or red highlights)
vim.opt.list = true
vim.opt.listchars = {
  tab = '» ',
  trail = '•',      -- Character to display for trailing whitespace
  nbsp = '␣',
}

-- 2. Highlight consecutive spaces (2 or more spaces in a row) and trailing whitespace
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  pattern = "*",
  callback = function()
    -- Highlight 2 or more spaces in a row
    vim.fn.matchadd("ExtraWhitespace", " \\{2,}")
    -- Highlight trailing whitespace
    vim.fn.matchadd("ExtraWhitespace", "\\s\\+$")
  end,
})

-- 3. Define a distinct background/foreground color for the highlight
vim.api.nvim_set_hl(0, "ExtraWhitespace", { bg = "#e06c75", fg = "#ffffff" })
```

Install Atone.nvim for the undo/ redo tree:
https://github.com/XXiaoA/atone.nvim

| Feature | Supported |
|---------|-----------|
| Debugger | ❌ |
| Colour Scheme for everything | ✅ |
| Menu Bar | ✅ |
| Status Bar (At bottom of screen) | ✅ |
| Tree file manager | ✅ |
| Display file icons in file manager | ✅ |
| Update a bracket/symbol and its corresponding bracket/symbol automatically | ✅ |
| Syntax Highlighting | ✅ |
| Format code on save | ❌ |
| Linting | ❌ |
| Collapse/Expand snippets of code | ❌ |
| Go to line | ✅ |
| Undo/Redo tree | ❌ |
| Vertical lines to show indent levels | ✅ |
| Minimap | ✅ |
| Markdown preview | ❌ |
| Automated indentation | ✅ |
| Comment toggler | ✅ |
| Show trailing whitespace and whitespace more than 1 character | ❌ |
| Highlight corresponding bracket | ✅ |
| Ensure I can copy paste text in Neovim when using it from within Tmux | ❌ |
| No need for search and replace. Use grep and fzf | ❌ |
| Write docs for how to use Neovim | ❌ |
| Look at Neovim ALE | ❌ |

Once I can view git output in Neovim, remove the unset PAGER line from the installing apps file. Set the pager to Neovim on my actual computer

Update the Nvim-Treesitter plugin. Add syntax highlighting for Dart and JavaScript and C (I have already added it to the main repo. I still need to test it and configure it)
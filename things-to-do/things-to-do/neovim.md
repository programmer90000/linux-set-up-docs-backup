1. Install this plugin to view output of commands in Neovim: [https://github.com/lucc/nvimpager](https://github.com/lucc/nvimpager)

2. Install this plugin to view MD files in Neovim: [https://github.com/MeanderingProgrammer/render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)
3. Display trailing whitespace and whitespace larger than 1 character. To do this, Add this to init.lua. Note that before adding this, I need to ensure it doesn't highlight space before a line (indentation):
```
-- 1. Enable list mode and show trailing spaces as dots (or red highlights)
vim.opt.list = true
vim.opt.listchars = {
  tab = '» ',
  trail = '•',      -- Character to display for trailing whitespace
  nbsp = '␣',
}

-- 2. Highlight consecutive spaces (2 or more inside code) and trailing whitespace
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  pattern = "*",
  callback = function()
    -- Clear previous matches in the current window to prevent duplicates
    vim.fn.clearmatches()

    -- Highlight 2 or more consecutive spaces ONLY after non-whitespace text
    vim.fn.matchadd("ExtraWhitespace", "\\S\\zs \\{2,}")

    -- Highlight trailing whitespace ONLY on lines that contain actual text
    vim.fn.matchadd("ExtraWhitespace", "\\S.*\\s\\+$")
  end,
})

-- 3. Define a distinct background/foreground color for the highlight
vim.api.nvim_set_hl(0, "ExtraWhitespace", { bg = "#e06c75", fg = "#ffffff" })
```
4. Install Atone.nvim for the undo/ redo tree:
https://github.com/XXiaoA/atone.nvim

Enable Collapse/Expand snippets of code inside the Treesitter plugin

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

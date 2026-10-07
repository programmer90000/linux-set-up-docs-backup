1. I have installed Nvim-dap. It works. I now need to install debuggers for specific languages. To do this, make a Node js file about 15 lines long containing a logic error in the middle. Paste it into AI and ask it how I can debug it using Nvim-dap. I should then create a custom tabbed UI, not download one. Use Nuicomponents to make the tabbed UI
2. Setup diffview. Install: https://github.com/barrettruth/diffs.nvim This allows the diffs to contain Treesitter syntax highlighting
3. Add linting for all languages
4. Set the code to lint, format and update on save

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
| Format code on save (Use Neovim ALE) | ❌ |
| Linting (Use Neovim ALE) | ❌ |
| Collapse/Expand snippets of code | ✅ |
| Go to line | ✅ |
| Undo/Redo tree | ✅ |
| Vertical lines to show indent levels | ✅ |
| Minimap | ✅ |
| Markdown preview | ✅ |
| Automated indentation | ✅ |
| Comment toggler | ✅ |
| Show trailing whitespace and whitespace more than 1 character | ✅ |
| Highlight corresponding bracket | ✅ |
| Ensure I can copy paste text in Neovim when using it from within Tmux | ✅ |
| Write docs for how to use Neovim | ❌ |
| Setup the default diffview | ❌ |

Update the Nvim-Treesitter plugin. Add syntax highlighting for Dart and JavaScript and C (I have already added it to the main repo. I still need to test it and configure it)

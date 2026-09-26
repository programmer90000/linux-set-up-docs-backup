-- Simulate dropdown menus using Telescope
local function menu()
  -- File menu
  vim.api.nvim_create_user_command('FileMenu', function()
    vim.ui.select(
      {'New File', 'Open File', 'Save File', 'Save As', 'Close Tab'},
      { prompt = 'File Menu:' },
      function(choice)
        if choice == 'New File' then vim.cmd('enew')
        elseif choice == 'Open File' then vim.cmd('Telescope find_files')
        elseif choice == 'Save File' then vim.cmd('w')
        elseif choice == 'Save As' then vim.cmd('saveas')
        elseif choice == 'Close Tab' then vim.cmd('tabclose')
        end
      end
    )
  end, {})

  -- Edit menu
  vim.api.nvim_create_user_command('EditMenu', function()
    vim.ui.select(
      {'Undo', 'Redo', 'Cut', 'Copy', 'Paste', 'Find', 'Select All'},
      { prompt = 'Edit Menu:' },
      function(choice)
        -- Implement actions here
        print('Selected: ' .. choice)
      end
    )
  end, {})
end

menu()

-- Quick access to menus
vim.keymap.set('n', '<F1>', '<cmd>FileMenu<cr>', { desc = 'Open File menu' })
vim.keymap.set('n', '<F2>', '<cmd>EditMenu<cr>', { desc = 'Open Edit menu' })
#!/bin/bash

PLUGIN_NAME="dap-sidebar-pro"
INSTALL_PATH="$HOME/.local/share/nvim/site/pack/dev/start/$PLUGIN_NAME"

echo "🚀 Installing Enhanced DAP Sidebar..."

mkdir -p "$INSTALL_PATH/lua/$PLUGIN_NAME"
mkdir -p "$INSTALL_PATH/plugin"

cat <<EOF > "$INSTALL_PATH/lua/$PLUGIN_NAME/init.lua"
local M = {}
local dap = require('dap')

M.buf = nil
M.win = nil
-- All possible data tabs
M.tabs = { "SCOPES", "BREAKPOINTS", "STACKS", "THREADS", "WATCHES", "EXCEPTIONS" }
M.current_tab_idx = 1
M.watch_expressions = { "status", "config" } -- Example watch expressions

_G.DapSidebarClick = function(id)
  M.current_tab_idx = id
  M.render()
end

local function get_dap_content()
  local session = dap.session()
  if not session then
    return { "  [ No active session ]", "", "  Start debugging to see info." }
  end

  local tab_name = M.tabs[M.current_tab_idx]
  local lines = { "  [ " .. tab_name .. " ]", "" }

  if tab_name == "SCOPES" then
    local scopes = session.current_frame and session.current_frame.scopes or {}
    for _, scope in ipairs(scopes) do
      table.insert(lines, "  " .. scope.name)
      table.insert(lines, "   (Use dap.ui.widgets for tree view)")
    end

  elseif tab_name == "BREAKPOINTS" then
    local breakpoints = require('dap.breakpoints').get()
    for bufnr, bp_list in pairs(breakpoints) do
      local name = vim.api.nvim_buf_get_name(bufnr):match("^.+/(.+)$") or "Unknown"
      for _, bp in ipairs(bp_list) do
        table.insert(lines, string.format("  %s : Line %d", name, bp.line))
      end
    end

  elseif tab_name == "STACKS" then
    local session = dap.session()
    -- Show frames for the current thread
    local frames = session.current_frame and {session.current_frame} or {}
    for _, frame in ipairs(frames) do
        table.insert(lines, string.format("  %s (%s:%d)", frame.name, frame.source.name or "???", frame.line))
    end

  elseif tab_name == "THREADS" then
    for _, thread in pairs(session.threads or {}) do
      local marker = (thread.id == session.current_thread_id) and "● " or "  "
      table.insert(lines, string.format("%s %s (ID: %d)", marker, thread.name or "Thread", thread.id))
    end

  elseif tab_name == "WATCHES" then
    for _, expr in ipairs(M.watch_expressions) do
      table.insert(lines, "  " .. expr .. ": (Pending evaluate...)")
    end
    table.insert(lines, "")
    table.insert(lines, "  [Press 'a' to add watch]")

  elseif tab_name == "EXCEPTIONS" then
    -- Pull capabilities from the specific debug adapter
    local filters = session.capabilities.exceptionBreakpointFilters or {}
    if #filters == 0 then
        table.insert(lines, "  No exception filters supported.")
    else
        for _, filter in ipairs(filters) do
            table.insert(lines, "  [" .. filter.filter .. "] " .. filter.label)
        end
    end
  end

  return lines
end

function M.render()
  if not M.buf or not vim.api.nvim_buf_is_valid(M.buf) then return end
  
  local lines = get_dap_content()
  
  vim.api.nvim_set_option_value("modifiable", true, { buf = M.buf })
  vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = M.buf })

  local bar_str = ""
  for i, name in ipairs(M.tabs) do
    local hl = (i == M.current_tab_idx) and "%#TabLineSel#" or "%#TabLine#"
    bar_str = bar_str .. hl .. " %" .. i .. "@v:lua.DapSidebarClick@" .. name .. " %X"
  end
  
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    vim.api.nvim_set_option_value("winbar", bar_str, { win = M.win })
  end
end

function M.toggle()
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    vim.api.nvim_win_close(M.win, true)
    M.win = nil
    return
  end

  M.buf = vim.api.nvim_create_buf(false, true)
  -- Reverted to "left" sidebar for better readability of 6 tabs
  M.win = vim.api.nvim_open_win(M.buf, true, { split = "below", height = 10 })
  
  vim.api.nvim_set_option_value("winfixwidth", true, { win = M.win })
  
  -- Keymaps
  vim.keymap.set("n", "q", M.toggle, { buffer = M.buf, silent = true })
  vim.keymap.set("n", "r", M.render, { buffer = M.buf, silent = true })
  vim.keymap.set("n", "a", function()
    vim.ui.input({ prompt = "Add Watch: " }, function(input)
        if input then 
            table.insert(M.watch_expressions, input)
            M.render()
        end
    end)
  end, { buffer = M.buf })

  -- Event Listeners
  dap.listeners.after.event_stopped['sidebar_pro'] = function() M.render() end
  dap.listeners.after.event_terminated['sidebar_pro'] = function() M.render() end

  M.render()
end

return M
EOF

cat <<EOF > "$INSTALL_PATH/plugin/$PLUGIN_NAME.lua"
vim.api.nvim_create_user_command("DapSidebar", function()
  require("$PLUGIN_NAME").toggle()
end, {})
EOF

echo "✅ DAP Sidebar Pro Installed! Run :DapSidebar"
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/plugins/neominimap/"))

vim.g.neominimap = {
  auto_enable = true,
  click = {
    enabled = true,
    auto_switch_focus = true,
  },
}
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    dashboard = { enabled = false },
    picker = {
      hidden = true,
      sources = {
        files = {
          hidden = true, -- Show hidden/dotfiles
        },
      },
    },
  },
}

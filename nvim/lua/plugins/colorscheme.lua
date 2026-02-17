return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      on_colors = function(colors)
        colors.bg = "#0a0b10"
        colors.bg_dark = "#06070b"
        colors.bg_float = "#0a0b10"
        colors.bg_sidebar = "#06070b"
      end,
    },
  },
}

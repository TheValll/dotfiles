return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      on_colors = function(colors)
        colors.bg = "#151821"
        colors.bg_dark = "#11141b"
        colors.bg_float = "#151821"
        colors.bg_sidebar = "#11141b"
      end,
    },
  },
}

return {
  -- Disable neo-tree keybindings
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      { "<leader>e", true },
      { "<leader>E", false },
      { "<leader>fe", false },
      { "<leader>fE", false },
    },
  },
  -- mini.files with <leader>e
  {
    "nvim-mini/mini.files",
    opts = {
      windows = {
        preview = true,
        width_focus = 50,
        width_preview = 75,
      },
      options = {
        use_as_default_explorer = true,
      },
    },
  },
  {
    "nvim-mini/mini.move",
    config = function(_, opts)
      require("mini.move").setup(opts)
    end,
  },
}

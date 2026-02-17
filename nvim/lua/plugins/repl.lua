return {

  {
    "geg2102/nvim-python-repl",
    dependencies = "nvim-treesitter",
    ft = { "python", "lua" },
    config = function()
      require("nvim-python-repl").setup({
        execute_on_send = true,
        vsplit = true,
        split_dir = "right",
      })

      vim.keymap.set("n", "<leader>rr", function()
        require("nvim-python-repl").send_statement_definition()
      end, { desc = "Send semantic unit to REPL" })
      vim.keymap.set("v", "<leader>rr", function()
        require("nvim-python-repl").send_visual_to_repl()
      end, { desc = "Send visual selection to REPL" })
    end,
  },
}

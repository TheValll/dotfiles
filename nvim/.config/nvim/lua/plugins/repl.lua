return {

  {
    "geg2102/nvim-python-repl",
    -- dir = '~/Documents/repos/externals/nvim-python-repl',
    dependencies = "nvim-treesitter",
    ft = { "python", "lua" }, -- 'ruby' },
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
      -- vim.keymap.set("n", [your keyamp], function() require('nvim-python-repl').send_buffer_to_repl() end, { desc = "Send entire buffer to REPL"})
      -- vim.keymap.set("n", [your keymap], function() require('nvim-python-repl').toggle_execute() end, { desc = "Automatically execute command in REPL after sent"})
      -- vim.keymap.set("n", [your keymap], function() require('nvim-python-repl').toggle_vertical() end, { desc = "Create REPL in vertical or horizontal split"})
      -- vim.keymap.set("n", "<leader>r", function()
      --   require("nvim-python-repl").open_repl()
      -- end, { desc = "Opens the REPL in a window split" })
    end,
  },
  -- {
  -- 	'milanglacier/yarepl.nvim',
  -- 	event = 'VeryLazy',
  -- 	config = true,
  -- },
}

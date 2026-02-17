-- ROS2 Jazzy support for LazyVim
return {
  -- 1. Configure clangd to find compile_commands.json from colcon workspaces
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("compile_commands.json", "build")(fname)
              or util.root_pattern("package.xml", "CMakeLists.txt")(fname)
              or util.find_git_ancestor(fname)
          end,
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                extraPaths = {
                  "/opt/ros/jazzy/lib/python3.12/site-packages",
                },
              },
            },
          },
        },
      },
    },
  },

  -- 2. Syntax highlighting for .msg, .srv, .action files
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.filetype.add({
        extension = {
          msg = "ros2msg",
          srv = "ros2srv",
          action = "ros2action",
        },
        filename = {
          ["package.xml"] = "xml",
        },
      })
    end,
  },

  -- 3. Simple syntax highlighting for ROS2 message types
  {
    dir = "",
    name = "ros2-ft",
    virtual = true,
    lazy = false,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "ros2msg", "ros2srv", "ros2action" },
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          vim.api.nvim_buf_call(buf, function()
            vim.cmd([[
              syntax match ros2Comment "#.*$"
              syntax match ros2Type "^\s*\(bool\|byte\|char\|float32\|float64\|int8\|int16\|int32\|int64\|uint8\|uint16\|uint32\|uint64\|string\|wstring\|time\|duration\)\>"
              syntax match ros2Type "\<\w\+\/"
              syntax match ros2Separator "^---$"
              syntax match ros2Constant "\<[A-Z_][A-Z0-9_]*\s*="
              highlight default link ros2Comment Comment
              highlight default link ros2Type Type
              highlight default link ros2Separator Special
              highlight default link ros2Constant Constant
            ]])
          end)
          vim.bo[buf].commentstring = "# %s"
        end,
      })
    end,
  },
}

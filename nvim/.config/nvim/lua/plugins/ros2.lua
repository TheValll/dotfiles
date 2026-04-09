-- ROS2 Jazzy support for LazyVim
return {
  -- 1. Configure clangd to find compile_commands.json from colcon workspaces
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          -- colcon generates compile_commands.json per package in build/
          -- clangd needs --compile-commands-dir or a root compile_commands.json
          -- We use root_dir to detect ROS2 workspaces
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("compile_commands.json", "build")(fname)
              or util.root_pattern("package.xml", "CMakeLists.txt")(fname)
              or util.find_git_ancestor(fname)
          end,
        },
        pyright = {
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("package.xml", "setup.py", "setup.cfg")(fname)
              or util.find_git_ancestor(fname)
          end,
          before_init = function(_, config)
            local root = config.root_dir or vim.fn.getcwd()
            local extra = {
              "/opt/ros/jazzy/lib/python3.12/site-packages",
            }
            -- Add colcon install paths from workspace
            local ws = root
            -- Walk up to find the colcon workspace (directory containing install/)
            while ws and ws ~= "/" do
              local install_dir = ws .. "/install"
              if vim.fn.isdirectory(install_dir) == 1 then
                local handle = vim.loop.fs_scandir(install_dir)
                if handle then
                  while true do
                    local name, typ = vim.loop.fs_scandir_next(handle)
                    if not name then break end
                    if typ == "directory" then
                      local sp = install_dir .. "/" .. name .. "/lib/python3.12/site-packages"
                      if vim.fn.isdirectory(sp) == 1 then
                        table.insert(extra, sp)
                      end
                    end
                  end
                end
                break
              end
              ws = vim.fn.fnamemodify(ws, ":h")
            end
            config.settings.python.analysis.extraPaths = extra
          end,
          settings = {
            python = {
              analysis = {
                extraPaths = {},
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
      -- ROS2 interface files use a simple syntax, set them as conf-like
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
      -- Syntax highlighting for .msg/.srv/.action
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "ros2msg", "ros2srv", "ros2action" },
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          -- Comments
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

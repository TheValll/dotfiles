local M = {}
local ns = vim.api.nvim_create_namespace('PersonalFlashFeedback')

-- Decorate only the prompt for this jump; Flash still handles all navigation.
function M.jump()
  local prompt = require('flash.prompt')
  local original_set = prompt.set
  local ignorecase, smartcase = vim.o.ignorecase, vim.o.smartcase
  local state, labeler
  local last_good = ''

  prompt.set = function(pattern, show)
    original_set(pattern, show)
    if not show or not prompt.visible() then return end
    vim.api.nvim_buf_clear_namespace(prompt.buf, ns, 0, -1)
    if not state or #state.results > 0 or pattern == '' then return end

    local prefix = 0
    for _, item in ipairs(require('flash.config').prompt.prefix) do
      prefix = prefix + #item[1]
    end
    local valid = pattern:sub(1, #last_good) == last_good and #last_good or 0
    if valid > 0 then
      vim.api.nvim_buf_set_extmark(prompt.buf, ns, 0, prefix, {
        end_col = prefix + valid, hl_group = 'PersonalFlashValid', priority = 200,
      })
    end
    if valid < #pattern then
      vim.api.nvim_buf_set_extmark(prompt.buf, ns, 0, prefix + valid, {
        end_col = prefix + #pattern, hl_group = 'PersonalFlashInvalid', priority = 200,
      })
    end
  end

  local ok, err = xpcall(function()
    -- Ignorer la casse uniquement pendant la recherche Flash.
    vim.o.ignorecase = true
    vim.o.smartcase = false
    require('flash').jump({
      labeler = function(matches, current)
        state = current
        labeler = labeler or require('flash.labeler').new(current):labeler()
        labeler(matches, current)
        if #matches > 0 then last_good = current.pattern() end
      end,
    })
  end, debug.traceback)
  vim.o.ignorecase, vim.o.smartcase = ignorecase, smartcase
  prompt.set = original_set
  if not ok then error(err) end
end

return M

local M = {}

local function label(tab)
  local custom = vim.t[tab].personal_tab_name
  if custom and custom ~= '' then return custom end
  local win = vim.api.nvim_tabpage_get_win(tab)
  if vim.api.nvim_win_get_config(win).relative ~= '' then
    for _, candidate in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      if vim.api.nvim_win_get_config(candidate).relative == '' then win = candidate; break end
    end
  end
  local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
  return name ~= '' and vim.fs.basename(name) or 'Sans nom'
end

function _G.PersonalTabline()
  local parts = {}
  local active = vim.api.nvim_get_current_tabpage()
  for index, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local name = label(tab):gsub('[\r\n\t]', ' '):gsub('%%', '%%%%')
    parts[#parts + 1] = '%' .. index .. 'T'
      .. (tab == active and '%#TabLineSel#' or '%#TabLine#')
      .. ' ' .. index .. ': ' .. name .. ' '
  end
  parts[#parts + 1] = '%T%#TabLineFill#%='
  return table.concat(parts)
end

vim.opt.showtabline = 2
vim.opt.tabline = '%!v:lua.PersonalTabline()'

function M.rename()
  local tab = vim.api.nvim_get_current_tabpage()
  vim.ui.input({ prompt = 'Nom de l onglet', default = label(tab) }, function(name)
    if not name or vim.trim(name) == '' or not vim.api.nvim_tabpage_is_valid(tab) then return end
    vim.t[tab].personal_tab_name = vim.trim(name)
    vim.cmd.redrawtabline()
  end)
end

function M.close()
  if #vim.api.nvim_list_tabpages() == 1 then
    vim.notify('Dernier onglet : Espace q pour quitter Neovim.', vim.log.levels.INFO)
    return
  end
  vim.cmd('confirm tabclose')
end

vim.keymap.set('n', 'H', '<cmd>tabprevious<CR>', { desc = 'Onglet a gauche' })
vim.keymap.set('n', 'L', '<cmd>tabnext<CR>', { desc = 'Onglet a droite' })
vim.keymap.set('n', '<leader>tn', '<cmd>tabnew<CR>', { desc = 'Nouvel onglet' })
vim.keymap.set('n', '<leader>td', M.close, { desc = 'Fermer l onglet' })
vim.keymap.set('n', '<leader>tr', M.rename, { desc = 'Renommer l onglet' })

return M

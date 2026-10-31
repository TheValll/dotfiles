local M = {}
local files = require('mini.files')
local uv = vim.uv

local function notify(message)
  vim.notify(message, vim.log.levels.WARN, { title = 'mini.files' })
end

local function context()
  local state = files.get_explorer_state()
  if not state then return end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].filetype == 'minifiles' and vim.bo[buf].modified then
      notify('Valide ou annule les modifications en cours dans mini.files.')
      return
    end
  end
  for _, window in ipairs(state.windows) do
    if window.win_id == vim.api.nvim_get_current_win() then
      local stat = uv.fs_stat(window.path)
      if stat and stat.type == 'directory' then
        return window.path, files.get_fs_entry()
      end
    end
  end
end

local function target_path(directory, name)
  if not name or vim.trim(name) == '' then return end
  name = vim.trim(name):gsub('\\', '/')
  if name:find('[/:%z]') or name == '.' or name == '..' then
    notify('Saisis un nom simple, sans chemin ni separateur.')
    return
  end
  return vim.fs.joinpath(directory, name)
end

local function buffers_under(path)
  local result = {}
  local prefix = vim.fs.normalize(path):lower()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == '' then
      local name = vim.fs.normalize(vim.api.nvim_buf_get_name(buf))
      local lower = name:lower()
      if lower == prefix or lower:sub(1, #prefix + 1) == prefix .. '/' then
        result[#result + 1] = { buf = buf, suffix = name:sub(#prefix + 1) }
      end
    end
  end
  return result
end

local function refresh()
  if files.get_explorer_state() then files.synchronize() end
end

function M.create()
  local directory = context()
  if not directory then return end
  vim.ui.input({ prompt = 'Nouveau fichier - Espace Entree pour confirmer' }, function(name)
    local path = target_path(directory, name)
    if not path then return end
    local fd, err = uv.fs_open(path, 'wx', 420)
    if not fd then notify('Creation impossible : ' .. tostring(err)); return end
    uv.fs_close(fd)
    refresh()
  end)
end

function M.rename()
  local directory, entry = context()
  if not entry then return end
  vim.ui.input({ prompt = 'Renommer - Espace Entree pour confirmer', default = entry.name }, function(name)
    local target = target_path(directory, name)
    if not target or target == entry.path then return end
    if uv.fs_lstat(target) and target:lower() ~= entry.path:lower() then
      notify('Ce nom existe deja. Aucun fichier remplace.')
      return
    end
    local buffers = buffers_under(entry.path)
    for _, item in ipairs(buffers) do
      local other = vim.fn.bufnr(target .. item.suffix)
      if other >= 0 and other ~= item.buf then
        notify('Un autre buffer utilise deja ce nom.')
        return
      end
    end
    local ok, err = uv.fs_rename(entry.path, target)
    if not ok then notify('Renommage impossible : ' .. tostring(err)); return end
    for _, item in ipairs(buffers) do
      vim.api.nvim_buf_set_name(item.buf, target .. item.suffix)
    end
    refresh()
  end)
end

function M.delete()
  local _, entry = context()
  if not entry then return end
  if vim.fn.confirm('Supprimer ' .. entry.name .. ' vers la corbeille ?', '&Yes\n&No', 2) ~= 1 then return end
  local buffers = buffers_under(entry.path)
  for _, item in ipairs(buffers) do
    if vim.bo[item.buf].modified then
      notify('Enregistre ou ferme les modifications avant de supprimer cette entree.')
      return
    end
  end
  local trash = vim.fs.joinpath(vim.fn.stdpath('data'), 'file-trash',
    os.date('%Y%m%d-%H%M%S') .. '-' .. tostring(uv.hrtime()))
  vim.fn.mkdir(trash, 'p')
  local target = vim.fs.joinpath(trash, entry.name)
  local ok, err = uv.fs_rename(entry.path, target)
  if not ok then notify('Suppression impossible : ' .. tostring(err)); return end
  for _, item in ipairs(buffers) do vim.api.nvim_buf_delete(item.buf, {}) end
  refresh()
  vim.notify('Deplace dans la corbeille : ' .. target, vim.log.levels.INFO)
end

return M

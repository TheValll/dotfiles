-- Configuration personnelle : ajoutons les raccourcis un par un.
-- Neovim herite de la police configuree dans le terminal.
require('config.clipboard')

-- Theme partage avec les terminaux : OneDark Darker.
local apply_ui_theme = require('config.theme').apply_ui
vim.api.nvim_create_autocmd('User', {
  group = vim.api.nvim_create_augroup('PersonalExplorerTheme', { clear = true }),
  pattern = 'MiniFilesWindowOpen',
  callback = apply_ui_theme,
})

-- Espace est le prefixe des raccourcis en mode normal.
vim.g.mapleader = ' '
vim.keymap.set('n', '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', '<leader><CR>', '<cmd>nohlsearch<CR>', { desc = 'Effacer le surlignage de recherche' })
vim.keymap.set('n', 'U', '<C-r>', { desc = 'Refaire la derniere modification annulee' })
vim.keymap.set('n', 'a', 'i', { desc = 'Inserer avant le curseur' })
vim.keymap.set('n', 'i', 'a', { desc = 'Inserer apres le curseur' })

-- Afficher le fichier courant en haut de chaque fenetre, sans statut en bas.
vim.opt.winbar = ' %t'
vim.opt.laststatus = 0
vim.opt.ruler = false
vim.opt.number = true

-- Ctrl+d/u defilent l'ecran sans deplacer le curseur ; Ctrl+e/y gardent
-- les mouvements natifs d'une demi-page.
vim.keymap.set('n', '<C-d>', '<C-e>', { desc = 'Defiler vers le bas sans deplacer le curseur' })
vim.keymap.set('n', '<C-u>', '<C-y>', { desc = 'Defiler vers le haut sans deplacer le curseur' })
vim.keymap.set('n', '<C-e>', '<C-d>', { desc = 'Descendre d une demi-page avec le curseur' })
vim.keymap.set('n', '<C-y>', '<C-u>', { desc = 'Remonter d une demi-page avec le curseur' })

-- Tab/Shift+Tab indentent la selection et la restaurent pour les repetitions.
vim.keymap.set('x', '<Tab>', '>gv', { desc = 'Indenter la selection' })
vim.keymap.set('x', '<S-Tab>', '<lt>gv', { desc = 'Desindenter la selection' })
vim.keymap.set('x', '<lt>', '<Nop>', { desc = 'Utiliser Maj+Tab pour desindenter' })
vim.keymap.set('x', '>', '<Nop>', { desc = 'Utiliser Tab pour indenter' })

vim.keymap.set('n', '<leader>s', '<cmd>write<CR>', { desc = 'Enregistrer le fichier' })

-- Demander confirmation si des fichiers ne sont pas enregistres.
vim.keymap.set('n', '<leader>q', '<cmd>confirm qall<CR>', {
  desc = 'Quitter Neovim',
})

-- Fenetres : nouvelles divisions a droite et en dessous.
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.keymap.set('n', '<leader>wv', '<cmd>vsplit<CR>', { desc = 'Division verticale' })
vim.keymap.set('n', '<leader>wh', '<cmd>split<CR>', { desc = 'Division horizontale' })
vim.keymap.set('n', '<leader>w=', '<C-w>=', { desc = 'Egaliser les tailles' })
vim.keymap.set('n', '<leader>wq', '<cmd>confirm close<CR>', { desc = 'Fermer la fenetre' })

for key, direction in pairs({ h = 'gauche', j = 'bas', k = 'haut', l = 'droite' }) do
  vim.keymap.set('n', '<C-' .. key .. '>', '<C-w>' .. key, {
    desc = 'Focus vers ' .. direction,
  })
  vim.keymap.set('n', '<leader>w' .. key:upper(), '<C-w>' .. key:upper(), {
    desc = 'Deplacer la fenetre vers ' .. direction,
  })
end

-- mini.files : les colonnes des dossiers parents restent visibles.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.cmd.packadd('mini.files')
local files = require('mini.files')
files.setup({
  windows = { preview = true, width_focus = 50, width_preview = 75 },
  options = { use_as_default_explorer = true },
  mappings = { go_in = 'l', go_out = 'h' },
  content = {
    -- Des reperes simples compatibles avec Consolas, sans police a icones.
    prefix = function(entry)
      if entry.fs_type == 'directory' then return '+ ', 'MiniFilesDirectory' end
      return '  ', 'MiniFilesFile'
    end,
  },
})
vim.api.nvim_create_autocmd('User', {
  group = vim.api.nvim_create_augroup('PersonalMiniFilesKeys', { clear = true }),
  pattern = 'MiniFilesBufferCreate',
  callback = function(event)
    vim.keymap.set('n', '<Esc>', files.close, {
      buffer = event.data.buf_id,
      nowait = true,
      desc = 'Fermer l explorateur',
    })
    local actions = require('config.file_actions')
    local opts = { buffer = event.data.buf_id, silent = true }
    vim.keymap.set('n', 'd', '<Nop>', vim.tbl_extend('force', opts, { desc = 'Utiliser Espace d pour supprimer' }))
    vim.keymap.set('n', 'i', '<Nop>', vim.tbl_extend('force', opts, { desc = 'Utiliser Espace n ou Espace r' }))
    vim.keymap.set('n', '<leader>n', actions.create, vim.tbl_extend('force', opts, { desc = 'Nouveau fichier' }))
    vim.keymap.set('n', '<leader>r', actions.rename, vim.tbl_extend('force', opts, { desc = 'Renommer' }))
    vim.keymap.set('n', '<leader>d', actions.delete, vim.tbl_extend('force', opts, { desc = 'Supprimer' }))
  end,
})
vim.keymap.set('n', '<leader>e', function()
  if files.get_explorer_state() then
    files.close()
    return
  end
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' or not vim.uv.fs_stat(path) then path = vim.fn.getcwd() end
  files.open(path)
end, {
  desc = 'Ouvrir ou fermer l explorateur',
})

-- Utiliser directement le ripgrep installe, sans dependre du PATH du terminal.
local rg_program = vim.fn.exepath('rg')
if rg_program == '' then rg_program = 'rg' end
if rg_program ~= '' and vim.uv.fs_stat(rg_program) then
  vim.env.PATH = vim.fs.dirname(rg_program) .. (vim.fn.has('win32') == 1 and ';' or ':') .. (vim.env.PATH or '')
end

local function current_project_root()
  local path = vim.api.nvim_buf_get_name(0)
  local explorer = files.get_explorer_state()
  if explorer then path = explorer.anchor end
  local stat = vim.uv.fs_stat(path)
  if not stat then path = vim.fn.getcwd(); stat = vim.uv.fs_stat(path) end
  local directory = stat and stat.type == 'directory' and path or vim.fs.dirname(path)
  return vim.fs.root(path, '.git') or directory
end

local function find_project_files(opts, ctx)
  local args = { '--files', '--no-messages', '--color', 'never', '-g', '!.git' }
  if opts.hidden then table.insert(args, '--hidden') end
  if opts.ignored then table.insert(args, '--no-ignore') end
  return require('snacks.picker.source.proc').proc(ctx:opts({
    cmd = rg_program,
    args = args,
    cwd = opts.cwd,
    transform = function(item)
      item.file = item.text
      item.cwd = opts.cwd
    end,
  }), ctx)
end

-- Recherche de fichiers Snacks. Alt+p affiche ou masque l apercu.
vim.cmd.packadd('snacks.nvim')
local snacks = require('snacks')
snacks.setup({
  dashboard = {
    enabled = true,
    preset = { keys = {} },
    -- Logo natif de Neovim 0.12 et version, dans la couleur du theme.
    sections = {
      { text = { { '│ ╲ ││', hl = 'Normal' } }, align = 'center' },
      { text = { { '││╲╲││', hl = 'Normal' } }, align = 'center' },
      { text = { { '││ ╲ │', hl = 'Normal' } }, align = 'center' },
      {
        text = { { 'NVIM v' .. tostring(vim.version()), hl = 'Normal' } },
        align = 'center',
        padding = { 0, 1 },
      },
    },
  },
  input = {
    enabled = true,
    icon = '',
    win = {
      on_win = apply_ui_theme,
      keys = {
        ['<Space><CR>'] = { 'confirm', mode = { 'i', 'n' } },
        i_esc = { '<Esc>', 'cancel', mode = 'i' },
      },
    },
  },
  image = { enabled = false },
  picker = {
    enabled = true,
    on_show = apply_ui_theme,
    prompt = '> ',
    icons = { files = { enabled = false } },
    sources = {
      files = {
        hidden = true,
        finder = find_project_files,
        layout = {
          preset = 'vscode',
          layout = { width = 0.8, min_width = 40, height = 0.7 },
        },
      },
    },
    win = {
      input = {
        keys = {
          ['<C-j>'] = { 'list_down', mode = { 'i', 'n' }, nowait = true },
          ['<C-k>'] = { 'list_up', mode = { 'i', 'n' }, nowait = true },
        },
      },
      list = {
        keys = {
          ['<C-j>'] = { 'list_down', nowait = true },
          ['<C-k>'] = { 'list_up', nowait = true },
        },
      },
    },
  },
})
snacks.input.enable()
apply_ui_theme()
vim.keymap.set('n', '<leader><Space>', function()
  local path = vim.api.nvim_buf_get_name(0)
  local explorer = files.get_explorer_state()
  if explorer then
    path = explorer.anchor
    if files.close() == false then return end
  end
  local stat = vim.uv.fs_stat(path)
  if not stat then path = vim.fn.getcwd(); stat = vim.uv.fs_stat(path) end
  local directory = stat and stat.type == 'directory' and path or vim.fs.dirname(path)
  local root = vim.fs.root(path, '.git') or directory
  snacks.picker.files({ cwd = root, title = 'Fichiers - ' .. vim.fs.basename(root) })
end, {
  desc = 'Rechercher un fichier dans le projet',
})
vim.keymap.set('n', '<leader>lg', function()
  local lazygit = vim.fn.exepath('lazygit')
  if lazygit == '' then
    vim.notify('Lazygit est introuvable dans le PATH.', vim.log.levels.ERROR)
    return
  end
  snacks.terminal.toggle(lazygit, { cwd = current_project_root() })
end, {
  desc = 'Ouvrir Lazygit dans le projet',
})

-- Flash : lancement avec Espace F, sans remplacer les raccourcis natifs.
vim.cmd.packadd('flash.nvim')
local flash = require('flash')
flash.setup({
  -- Le mode recherche reste ouvert meme quand aucun resultat ne correspond.
  search = { mode = 'search' },
})
vim.keymap.set({ 'n', 'x', 'o' }, '<leader>f', function() require('config.flash').jump() end, { desc = 'Flash' })

require('config.languages')
require('config.tabs')
require('config.dial')

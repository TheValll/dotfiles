local M = {}
vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.cmd.packadd('onedark.nvim')
require('onedark').setup({
  style = 'darker',
  term_colors = true,
  colors = {
    fg = '#a0a5ad', red = '#c87979', orange = '#c49a72', yellow = '#c2ae7b',
    green = '#9aa889', blue = '#83a0be', purple = '#a58db0', cyan = '#82a6a5',
    grey = '#68717d', light_grey = '#858c96',
    diff_add = '#29302c', diff_delete = '#342b2c', diff_change = '#29313b', diff_text = '#354554',
  },
})

local function colors()
  local c = require('onedark.colors')
  return {
    bg0 = c.bg0, bg_dim = c.bg_d, bg1 = c.bg1, bg2 = c.bg2, bg3 = c.bg3,
    fg = c.fg, red = c.red, orange = c.orange, yellow = c.yellow,
    green = c.green, blue = c.blue, purple = c.purple, aqua = c.cyan,
    grey0 = c.grey, grey1 = c.light_grey, grey2 = c.grey,
    bg_green = c.diff_add, bg_red = c.diff_delete,
  }
end

function M.apply_ui()
  if vim.g.colors_name ~= 'onedark' then return end
  local p = colors()
  local groups = {
    NormalNC = { fg = p.fg, bg = p.bg_dim },
    WinSeparator = { fg = p.grey2, bg = p.bg_dim },
    VertSplit = { fg = p.grey2, bg = p.bg_dim },
    NormalFloat = { fg = p.fg, bg = p.bg1 },
    FloatBorder = { fg = p.grey2, bg = p.bg1 },
    FloatTitle = { fg = p.green, bg = p.bg1, bold = true },
    MiniFilesNormal = { fg = p.fg, bg = p.bg1 },
    MiniFilesBorder = { fg = p.grey2, bg = p.bg1 },
    MiniFilesBorderModified = { fg = p.yellow, bg = p.bg1 },
    MiniFilesTitle = { fg = p.grey2, bg = p.bg1 },
    MiniFilesTitleFocused = { fg = p.blue, bg = p.bg1, bold = true },
    MiniFilesDirectory = { fg = p.blue },
    MiniFilesFile = { fg = p.fg },
    MiniFilesCursorLine = { fg = p.fg, bg = p.bg3 },
    SnacksInputNormal = { fg = p.fg, bg = p.bg1 },
    SnacksInputBorder = { fg = p.green, bg = p.bg1 },
    SnacksInputTitle = { fg = p.green, bg = p.bg1, bold = true },
    SnacksPicker = { fg = p.fg, bg = p.bg1 },
    SnacksPickerInput = { fg = p.fg, bg = p.bg1 },
    SnacksPickerList = { fg = p.fg, bg = p.bg1 },
    SnacksPickerPreview = { fg = p.fg, bg = p.bg1 },
    SnacksPickerBorder = { fg = p.grey2, bg = p.bg1 },
    SnacksPickerBoxBorder = { fg = p.grey2, bg = p.bg1 },
    SnacksPickerListBorder = { fg = p.grey2, bg = p.bg1 },
    SnacksPickerPreviewBorder = { fg = p.grey2, bg = p.bg1 },
    SnacksPickerInputBorder = { fg = p.green, bg = p.bg1 },
    SnacksPickerTitle = { fg = p.green, bg = p.bg1, bold = true },
    SnacksPickerInputTitle = { fg = p.green, bg = p.bg1, bold = true },
    SnacksPickerBoxTitle = { fg = p.green, bg = p.bg1, bold = true },
    SnacksPickerPrompt = { fg = p.green },
    SnacksPickerFile = { fg = p.fg },
    SnacksPickerDir = { fg = p.grey2 },
    SnacksPickerDirectory = { fg = p.green },
    SnacksPickerMatch = { fg = p.yellow, bold = true },
    SnacksPickerTotals = { fg = p.grey2 },
    SnacksPickerListCursorLine = { fg = p.fg, bg = p.bg_green },
    TabLine = { fg = p.fg, bg = p.bg1 },
    TabLineSel = { fg = p.bg_dim, bg = p.green, bold = true },
    TabLineFill = { fg = p.grey1, bg = p.bg_dim },
    WinBar = { fg = p.fg, bg = p.bg1, bold = true },
    WinBarNC = { fg = p.grey1, bg = p.bg1 },
  }
  for name, value in pairs(groups) do vim.api.nvim_set_hl(0, name, value) end
end

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('PersonalOneDarkTheme', { clear = true }),
  callback = function() vim.schedule(M.apply_ui) end,
})
vim.cmd.colorscheme('onedark')
M.apply_ui()
vim.opt.fillchars:append({ vert = '│', horiz = '─', horizup = '┴', horizdown = '┬',
  vertleft = '┤', vertright = '├', verthoriz = '┼' })
return M
-- Incrementer les nombres et basculer les booleens avec Ctrl+a / Ctrl+x.
vim.cmd.packadd('dial.nvim')

local augend = require('dial.augend')
require('dial.config').augends:register_group({
  default = {
    augend.integer.alias.decimal,
    augend.integer.alias.decimal_int,
    augend.integer.alias.hex,
    augend.constant.alias.bool,
    augend.constant.alias.Bool,
  },
})

local function set_dial_map(mode, key, operation, variant, description)
  vim.keymap.set(mode, key, function()
    return require('dial.map')[operation .. '_' .. variant]()
  end, { expr = true, desc = description })
end

set_dial_map('n', '<C-a>', 'inc', 'normal', 'Incrementer ou inverser')
set_dial_map('n', '<C-x>', 'dec', 'normal', 'Decrementer ou inverser')
set_dial_map('x', '<C-a>', 'inc', 'visual', 'Incrementer la selection')
set_dial_map('x', '<C-x>', 'dec', 'visual', 'Decrementer la selection')
set_dial_map('n', 'g<C-a>', 'inc', 'gnormal', 'Incrementer en sequence')
set_dial_map('n', 'g<C-x>', 'dec', 'gnormal', 'Decrementer en sequence')
set_dial_map('x', 'g<C-a>', 'inc', 'gvisual', 'Incrementer la selection en sequence')
set_dial_map('x', 'g<C-x>', 'dec', 'gvisual', 'Decrementer la selection en sequence')

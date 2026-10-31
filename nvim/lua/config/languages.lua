local M = {}

-- Ajouter les outils locaux usuels au PATH si necessaire.
local function add_path(path)
  if path and vim.fn.isdirectory(path) == 1 then
    local separator = vim.fn.has('win32') == 1 and ';' or ':'
    vim.env.PATH = path .. separator .. (vim.env.PATH or '')
  end
end
add_path(vim.fn.expand('~/.cargo/bin'))
add_path(vim.fn.expand('~/.local/bin'))
vim.g.tex_flavor = 'latex'
vim.opt.completeopt = { 'menuone', 'noselect', 'popup' }
local tree_sitter = vim.fn.exepath('tree-sitter')
if tree_sitter ~= '' then add_path(vim.fs.dirname(tree_sitter)) end

vim.cmd.packadd('nvim-treesitter')
require('nvim-treesitter').setup()
M.parsers = { 'c', 'cpp', 'rust', 'python', 'dockerfile', 'markdown', 'markdown_inline',
  'bash', 'nu', 'json', 'yaml', 'toml', 'latex', 'bibtex' }

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('PersonalLanguageColors', { clear = true }),
  pattern = { 'c', 'cpp', 'rust', 'python', 'dockerfile', 'markdown', 'sh', 'bash', 'nu', 'json', 'yaml', 'toml', 'tex', 'plaintex', 'bib' },
  callback = function(event)
    local ok = pcall(vim.treesitter.start, event.buf)
    -- La coloration native reste disponible si un analyseur est absent.
    if not ok then vim.bo[event.buf].syntax = vim.bo[event.buf].filetype end
  end,
})

vim.cmd.packadd('mason.nvim')
require('mason').setup({
  max_concurrent_installers = 3,
  ui = { border = 'rounded', icons = { package_installed = '+', package_pending = '>', package_uninstalled = '-' } },
})
M.packages = { 'clangd', 'pyright', 'dockerfile-language-server', 'marksman',
  'bash-language-server', 'shellcheck', 'yaml-language-server', 'texlab', 'json-lsp', 'taplo' }

vim.cmd.packadd('nvim-lspconfig')
local mason = vim.fn.stdpath('data') .. '/mason/packages/'

-- Les entrees Node sont lancees directement : pas de wrapper .cmd ni de shell.
local function node_command(package, module, binary, args)
  local root = mason .. package .. '/node_modules/' .. module
  local package_json = root .. '/package.json'
  if vim.fn.filereadable(package_json) ~= 1 then return nil end
  local meta = vim.json.decode(table.concat(vim.fn.readfile(package_json), '\n'))
  local entry = type(meta.bin) == 'string' and meta.bin or meta.bin[binary]
  return vim.list_extend({ vim.fn.exepath('node'), vim.fs.joinpath(root, entry) }, args)
end

local function installed_exe(package, name)
  local suffix = vim.fn.has('win32') == 1 and '.exe' or ''
  return vim.fn.glob(mason .. package .. '/**/' .. name .. suffix, false, true)[1]
end

local clangd = installed_exe('clangd', 'clangd')
if clangd then vim.lsp.config('clangd', { cmd = { clangd, '--background-index' } }) end
local marksman = installed_exe('marksman', 'marksman')
if marksman then vim.lsp.config('marksman', { cmd = { marksman, 'server' } }) end
local texlab = installed_exe('texlab', 'texlab')
if texlab then
  vim.lsp.config('texlab', {
    cmd = { texlab },
    -- Support du langage uniquement : pas de compilation automatique.
    settings = { texlab = { build = { onSave = false } } },
  })
end
local shellcheck = installed_exe('shellcheck', 'shellcheck')
if shellcheck then
  vim.lsp.config('bashls', { settings = { bashIde = { shellcheckPath = shellcheck } } })
end

for server, spec in pairs({
  pyright = { 'pyright', 'pyright', 'pyright-langserver', { '--stdio' } },
  dockerls = { 'dockerfile-language-server', 'dockerfile-language-server-nodejs', 'docker-langserver', { '--stdio' } },
  bashls = { 'bash-language-server', 'bash-language-server', 'bash-language-server', { 'start' } },
  yamlls = { 'yaml-language-server', 'yaml-language-server', 'yaml-language-server', { '--stdio' } },
}) do
  local cmd = node_command(unpack(spec))
  if cmd then vim.lsp.config(server, { cmd = cmd }) end
end

local json_cmd = node_command('json-lsp', 'vscode-langservers-extracted', 'vscode-json-language-server', { '--stdio' })
if json_cmd then
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  vim.lsp.config('jsonls', {
    cmd = json_cmd,
    capabilities = capabilities,
    workspace_required = false,
  })
end

local taplo = installed_exe('taplo', 'taplo')
if taplo then
  vim.lsp.config('taplo', { cmd = { taplo, 'lsp', 'stdio' }, workspace_required = false })
end

local rust_analyzer = vim.fn.exepath('rust-analyzer')
if rust_analyzer ~= '' then vim.lsp.config('rust_analyzer', { cmd = { rust_analyzer } }) end
local nu = vim.fn.exepath('nu')
if nu ~= '' then vim.lsp.config('nushell', { cmd = { nu, '--lsp' } }) end

M.servers = { 'clangd', 'rust_analyzer', 'pyright', 'dockerls', 'marksman', 'bashls', 'yamlls', 'texlab', 'jsonls', 'taplo' }
if nu ~= '' then table.insert(M.servers, 'nushell') end
vim.lsp.enable(M.servers)

-- Completion native Neovim : ouvrir la liste sur les caracteres saisis.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('PersonalLanguageCompletion', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      local provider = client.server_capabilities.completionProvider
      local trigger_chars, seen = provider.triggerCharacters or {}, {}
      for _, char in ipairs(trigger_chars) do seen[char] = true end
      for code = 32, 126 do
        local char = string.char(code)
        if not seen[char] then
          trigger_chars[#trigger_chars + 1] = char
          seen[char] = true
        end
      end
      provider.triggerCharacters = trigger_chars
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end
  end,
})

return M

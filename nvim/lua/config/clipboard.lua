-- macOS: pbcopy/pbpaste; Windows: win32yank; Linux: Wayland ou X11.
-- Neovim detecte ces outils automatiquement, sauf le pont WSL explicite.
if vim.fn.has('wsl') == 1 then
  local yank = vim.fn.exepath('win32yank.exe')
  if yank ~= '' then
    vim.g.clipboard = {
      name = 'Windows clipboard (WSL)',
      copy = { ['+'] = { yank, '-i', '--crlf' }, ['*'] = { yank, '-i', '--crlf' } },
      paste = { ['+'] = { yank, '-o', '--lf' }, ['*'] = { yank, '-o', '--lf' } },
      cache_enabled = 0,
    }
  elseif vim.fn.executable('powershell.exe') == 1 then
    local function command(script)
      return { 'powershell.exe', '-NoProfile', '-NonInteractive', '-Command', script }
    end
    local copy = command('[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false); Set-Clipboard -Value ([Console]::In.ReadToEnd())')
    local paste = command('[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false); [Console]::Write((Get-Clipboard -Raw).Replace("`r", ""))')
    vim.g.clipboard = {
      name = 'Windows clipboard (WSL PowerShell)',
      copy = { ['+'] = copy, ['*'] = copy },
      paste = { ['+'] = paste, ['*'] = paste },
      cache_enabled = 0,
    }
  end
end

-- y, p, d et c utilisent le presse-papiers systeme par defaut.
vim.opt.clipboard = 'unnamedplus'

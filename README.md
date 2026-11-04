# Dotfiles

## macOS

```sh
brew install alacritty neovim nushell tmux ripgrep lazygit node sesh zoxide atuin

DOTFILES="$HOME/dotfiles"
mkdir -p ~/.config/{alacritty,nvim,nushell,lazygit,theme}
cp "$DOTFILES/alacritty/alacritty.toml" ~/.config/alacritty/alacritty.toml
cp -R "$DOTFILES/nvim/." ~/.config/nvim/
cp "$DOTFILES/nushell/config.nu" ~/.config/nushell/config.nu
cp "$DOTFILES/lazygit/config.yml" ~/.config/lazygit/config.yml
cp "$DOTFILES/theme/onedark.json" ~/.config/theme/onedark.json
cp "$DOTFILES/tmux.conf" ~/.tmux.conf

mkdir -p ~/.atuin
atuin init nu > ~/.atuin/init.nu

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
mkdir -p ~/.local/share/nvim/site/pack/personal/start
cd ~/.local/share/nvim/site/pack/personal/start
git clone https://github.com/navarasu/onedark.nvim.git
git clone https://github.com/nvim-mini/mini.files.git
git clone https://github.com/folke/snacks.nvim.git
git clone https://github.com/monaqa/dial.nvim.git
git clone https://github.com/nvim-treesitter/nvim-treesitter.git
git clone https://github.com/mason-org/mason.nvim.git
git clone https://github.com/neovim/nvim-lspconfig.git
```

## Linux (Debian/Ubuntu)

```sh
sudo apt update
sudo apt install -y alacritty neovim nushell tmux ripgrep git nodejs npm golang-go zoxide wl-clipboard xclip
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh -s -- --non-interactive
mkdir -p ~/.atuin
~/.atuin/bin/atuin init nu > ~/.atuin/init.nu
go install github.com/jesseduffield/lazygit@latest
go install github.com/joshmedeski/sesh/v2@latest

DOTFILES="$HOME/dotfiles"
mkdir -p ~/.config/{alacritty,nvim,nushell,lazygit,theme}
cp "$DOTFILES/alacritty/alacritty.toml" ~/.config/alacritty/alacritty.toml
cp -R "$DOTFILES/nvim/." ~/.config/nvim/
cp "$DOTFILES/nushell/config.nu" ~/.config/nushell/config.nu
cp "$DOTFILES/lazygit/config.yml" ~/.config/lazygit/config.yml
cp "$DOTFILES/theme/onedark.json" ~/.config/theme/onedark.json
cp "$DOTFILES/tmux.conf" ~/.tmux.conf

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
mkdir -p ~/.local/share/nvim/site/pack/personal/start
cd ~/.local/share/nvim/site/pack/personal/start
git clone https://github.com/navarasu/onedark.nvim.git
git clone https://github.com/nvim-mini/mini.files.git
git clone https://github.com/folke/snacks.nvim.git
git clone https://github.com/monaqa/dial.nvim.git
git clone https://github.com/nvim-treesitter/nvim-treesitter.git
git clone https://github.com/mason-org/mason.nvim.git
git clone https://github.com/neovim/nvim-lspconfig.git
```

## Windows host (PowerShell)

```powershell
winget install --exact --id Alacritty.Alacritty
```

Alacritty runs the Linux tools inside WSL2. Install Nushell, Neovim, and tmux in Ubuntu using the WSL setup below; do not install the native Windows tmux port.

## Windows + WSL2

Run these commands in **PowerShell as Administrator**, then restart Windows:

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --set-default-version 2
```

After restarting, install Ubuntu and complete its first-launch username setup:

```powershell
wsl --install -d Ubuntu-24.04
```

In Ubuntu, clone the dotfiles and run the setup script:

```sh
sudo apt update && sudo apt install -y git
git clone https://github.com/TheValll/dotfiles "$HOME/dotfiles"
cd "$HOME/dotfiles"
bash scripts/setup-wsl.sh
```

The setup script also installs Atuin and configures searchable Nushell history.

The setup script installs Nushell, Neovim, tmux and the CLI tools, then copies the shared configs. Launch Alacritty with the WSL shell by changing its `[terminal.shell]` section to:

```toml
[terminal.shell]
program = "wsl.exe"
args = ["-d", "Ubuntu-24.04", "--cd", "~", "--", "/home/valentin/.local/bin/nu"]
```

To share history between machines, register Atuin once and sync. On the other machines, log in to the same account:

```sh
atuin register
atuin sync
```

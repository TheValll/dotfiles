#!/usr/bin/env bash
set -euo pipefail

# Run inside Ubuntu on WSL from the dotfiles repository.
sudo apt update
sudo apt install -y git tmux ripgrep nodejs npm golang-go zoxide curl ca-certificates build-essential

# Neovim's config uses APIs introduced in 0.11; Ubuntu's package can be older.
NVIM_VERSION="v0.11.4"
NVIM_ARCHIVE="nvim-linux-x86_64.tar.gz"
curl -fL "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_ARCHIVE}" -o "/tmp/${NVIM_ARCHIVE}"
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf "/tmp/${NVIM_ARCHIVE}"
sudo ln -sfn /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm -f "/tmp/${NVIM_ARCHIVE}"

# Install Nushell from its official release archive.
NU_VERSION="0.116.1"
NU_ARCHIVE="nu-${NU_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
curl -fL "https://github.com/nushell/nushell/releases/download/${NU_VERSION}/${NU_ARCHIVE}" -o "/tmp/${NU_ARCHIVE}"
mkdir -p "$HOME/.local/bin"
tar -xzf "/tmp/${NU_ARCHIVE}" -C /tmp
install "/tmp/nu-${NU_VERSION}-x86_64-unknown-linux-gnu/nu" "$HOME/.local/bin/nu"
rm -rf "/tmp/${NU_ARCHIVE}" "/tmp/nu-${NU_VERSION}-x86_64-unknown-linux-gnu"

# Atuin provides searchable Nushell history on Linux, macOS, and Windows/WSL.
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh -s -- --non-interactive
mkdir -p "$HOME/.atuin"
"$HOME/.atuin/bin/atuin" init nu > "$HOME/.atuin/init.nu"

export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
go install github.com/jesseduffield/lazygit@latest
go install github.com/joshmedeski/sesh/v2@latest

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$HOME/.config/nvim" "$HOME/.config/nushell" "$HOME/.config/lazygit" "$HOME/.config/theme"
cp -R "$DOTFILES/nvim/." "$HOME/.config/nvim/"
cp "$DOTFILES/nushell/config.nu" "$HOME/.config/nushell/config.nu"
cp "$DOTFILES/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
cp "$DOTFILES/theme/onedark.json" "$HOME/.config/theme/onedark.json"
cp "$DOTFILES/tmux.conf" "$HOME/.tmux.conf"

mkdir -p "$HOME/.tmux/plugins"
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
mkdir -p "$HOME/.local/share/nvim/site/pack/personal/start"
cd "$HOME/.local/share/nvim/site/pack/personal/start"
for repo in \
  https://github.com/navarasu/onedark.nvim.git \
  https://github.com/nvim-mini/mini.files.git \
  https://github.com/folke/snacks.nvim.git \
  https://github.com/monaqa/dial.nvim.git \
  https://github.com/nvim-treesitter/nvim-treesitter.git \
  https://github.com/mason-org/mason.nvim.git \
  https://github.com/neovim/nvim-lspconfig.git; do
  name="${repo##*/}"
  name="${name%.git}"
  [[ -d "$name" ]] || git clone "$repo"
done

printf '\nInstalled. Add ~/.local/bin and ~/go/bin to PATH if your shell does not see the tools.\n'
printf 'Start Nushell with: nu\nThen run: s\n'

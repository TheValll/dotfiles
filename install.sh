#!/bin/bash
# Dotfiles installer using GNU Stow
# Usage: ./install.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$DOTFILES_DIR/.backup/$(date +%Y%m%d_%H%M%S)"
cd "$DOTFILES_DIR"

# ============================================
# System packages
# ============================================
install_packages() {
    echo "Installing system packages..."

    # Core
    sudo apt update
    sudo apt install -y \
        zsh stow git curl wget \
        tmux kitty lsd btop \
        neovim ripgrep fd-find fzf

    # Starship (not in apt)
    if ! command -v starship &>/dev/null; then
        echo "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # Atuin (not in apt)
    if ! command -v atuin &>/dev/null; then
        echo "Installing Atuin..."
        curl -sSf https://setup.atuin.sh | bash
    fi

    # Set zsh as default shell
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo "Setting zsh as default shell..."
        chsh -s "$(which zsh)"
    fi
}

# ============================================
# Zsh & Tmux plugins (no sudo needed)
# ============================================
install_plugins() {
    # Oh-My-Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh-My-Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # Zsh plugins
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        echo "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        echo "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi

    # TPM (Tmux Plugin Manager)
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        echo "Installing TPM..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi

    # GTK Themes & Icons (manual install)
    mkdir -p "$HOME/.themes" "$HOME/.icons"
    echo "NOTE: Install themes manually if needed:"
    echo "  - GTK: sudo apt install flat-remix-gtk"
    echo "  - Icons: https://github.com/ful1e5/Bibata_Cursor"
    echo "  - Icons: sudo apt install flat-remix"
}

# ============================================
# Backup existing files before stow
# ============================================
backup_conflicts() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"

    while IFS= read -r -d '' file; do
        local rel="${file#$pkg_dir/}"
        local target="$HOME/$rel"

        if [ -e "$target" ] && [ ! -L "$target" ]; then
            local backup_path="$BACKUP_DIR/$pkg/$rel"
            mkdir -p "$(dirname "$backup_path")"
            mv "$target" "$backup_path"
            echo "    backup: $rel"
        fi
    done < <(find "$pkg_dir" -type f -print0)
}

# ============================================
# Main
# ============================================
packages=(
    zsh starship tmux kitty atuin
    nvim lazygit git
    hyprland waybar rofi swaync wlogout wallust ags swappy quickshell cava
    qt kvantum gtk
)

echo "=== Dotfiles installer ==="
echo ""

# Install packages (skip with --no-packages)
if [ "$1" != "--no-packages" ]; then
    install_packages
fi

install_plugins

echo ""
echo "Stowing packages..."
for pkg in "${packages[@]}"; do
    if [ -d "$pkg" ]; then
        backup_conflicts "$pkg"
        echo "  stow $pkg"
        stow -v -R -t "$HOME" "$pkg"
    fi
done

# Symlink .secret
if [ -f "$DOTFILES_DIR/.secret" ] && [ ! -f "$HOME/.secret" ]; then
    ln -s "$DOTFILES_DIR/.secret" "$HOME/.secret"
    echo "  linked .secret"
fi

echo ""
if [ -d "$BACKUP_DIR" ]; then
    echo "Backups saved to: $BACKUP_DIR"
fi
echo ""
echo "Done! Next steps:"
echo "  1. Fill in ~/.secret with your API keys and git profile"
echo "  2. Open tmux and press Ctrl+a then I to install tmux plugins"
echo "  3. Restart your shell (or: exec zsh)"

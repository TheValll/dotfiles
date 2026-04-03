#!/bin/bash
# Dotfiles installer using GNU Stow
# Usage: ./install.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$DOTFILES_DIR/.backup/$(date +%Y%m%d_%H%M%S)"
cd "$DOTFILES_DIR"

# ============================================
# Dependencies (installed if missing)
# ============================================
install_deps() {
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

    # GTK Themes
    THEMES_DIR="$HOME/.themes"
    if [ ! -d "$THEMES_DIR/Flat-Remix-GTK-Blue-Dark" ]; then
        echo "Installing GTK themes (Flat-Remix)..."
        mkdir -p "$THEMES_DIR"
        # sudo apt install flat-remix-gtk  # Ubuntu/Debian
    fi

    # Icon Themes
    ICONS_DIR="$HOME/.icons"
    if [ ! -d "$ICONS_DIR/Bibata-Modern-Ice" ]; then
        echo "Installing icon themes..."
        mkdir -p "$ICONS_DIR"
        # Bibata: https://github.com/ful1e5/Bibata_Cursor
        # Flat-Remix: sudo apt install flat-remix
    fi
}

# ============================================
# Backup existing files before stow
# ============================================
backup_conflicts() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"

    # Find all files that stow would create symlinks for
    while IFS= read -r -d '' file; do
        local rel="${file#$pkg_dir/}"
        local target="$HOME/$rel"

        # If target exists and is NOT already a symlink, back it up
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            local backup_path="$BACKUP_DIR/$pkg/$rel"
            mkdir -p "$(dirname "$backup_path")"
            mv "$target" "$backup_path"
            echo "    backup: $rel"
        fi
    done < <(find "$pkg_dir" -type f -print0)
}

# ============================================
# Stow packages
# ============================================
packages=(
    zsh starship tmux kitty atuin
    nvim lazygit git
    hyprland waybar rofi swaync wlogout wallust ags swappy quickshell cava
    qt kvantum gtk
)

echo "Installing dotfiles from $DOTFILES_DIR"

install_deps

has_backups=false
for pkg in "${packages[@]}"; do
    if [ -d "$pkg" ]; then
        backup_conflicts "$pkg"
        echo "  stow $pkg"
        stow -v -R -t "$HOME" "$pkg"
    fi
done

# Symlink .secret to home if it exists and isn't already there
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
echo "  3. Restart your shell"

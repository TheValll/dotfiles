#!/bin/bash
# Dotfiles installer using GNU Stow
# Usage:
#   ./install.sh                  Full install (packages + stow)
#   ./install.sh --no-packages    Stow only (skip apt)
#   ./install.sh --hyprland       Full install + Hyprland desktop

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$DOTFILES_DIR/.backup/$(date +%Y%m%d_%H%M%S)"
cd "$DOTFILES_DIR"

# ============================================
# Core packages (shell, terminal, dev tools)
# ============================================
install_packages() {
    echo "Installing core packages..."
    sudo apt update
    sudo apt install -y \
        zsh stow git curl wget \
        tmux kitty lsd btop \
        neovim ripgrep fd-find fzf \
        jq playerctl pamixer

    # Starship
    if ! command -v starship &>/dev/null; then
        echo "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # Atuin
    if ! command -v atuin &>/dev/null; then
        echo "Installing Atuin..."
        curl -sSf https://setup.atuin.sh | bash
    fi

    # Kanata (keyboard remapper)
    if ! command -v kanata &>/dev/null; then
        echo "Installing Kanata..."
        cargo install kanata
    fi

    # wl-kbptr (keyboard-driven mouse pointer)
    if ! command -v wl-kbptr &>/dev/null; then
        echo "Installing wl-kbptr..."
        sudo apt install -y meson ninja-build libwayland-dev wayland-protocols libxkbcommon-dev libcairo2-dev
        rm -rf /tmp/wl-kbptr
        git clone https://github.com/moverest/wl-kbptr.git /tmp/wl-kbptr
        meson setup /tmp/wl-kbptr/build /tmp/wl-kbptr --buildtype=release
        meson compile -C /tmp/wl-kbptr/build
        cp /tmp/wl-kbptr/build/wl-kbptr "$HOME/.local/bin/"
        rm -rf /tmp/wl-kbptr
    fi


    # Set zsh as default shell
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo "Setting zsh as default shell..."
        chsh -s "$(which zsh)"
    fi
}

# ============================================
# Hyprland desktop environment
# ============================================
install_hyprland() {
    echo "Installing Hyprland and desktop packages..."

    # Hyprland PPA (packages Hyprland + all deps for Ubuntu 24.04)
    if ! grep -q "cppiber/hyprland" /etc/apt/sources.list.d/*.list 2>/dev/null \
       && ! grep -q "cppiber/hyprland" /etc/apt/sources.list.d/*.sources 2>/dev/null; then
        echo "Adding Hyprland PPA..."
        sudo add-apt-repository -y ppa:cppiber/hyprland
        sudo apt update
    fi

    # Hyprland core + desktop tools
    sudo apt install -y \
        hyprland hyprlock hypridle \
        xdg-desktop-portal-hyprland \
        waybar rofi \
        sway-notification-center wlogout \
        grim slurp wl-clipboard cliphist \
        brightnessctl \
        pipewire wireplumber pavucontrol \
        blueman network-manager-gnome \
        thunar \
        policykit-1-gnome \
        cava \
        qt5-style-kvantum qt5ct qt6ct

    # Cargo packages (not in PPA)
    if command -v cargo &>/dev/null; then
        for pkg in swappy wallust; do
            if ! command -v "$pkg" &>/dev/null; then
                echo "Installing $pkg via cargo..."
                cargo install "$pkg"
            fi
        done
        if ! command -v swww &>/dev/null || ! command -v swww-daemon &>/dev/null; then
            echo "Installing swww via cargo..."
            cargo install swww swww-daemon --git https://github.com/LGFae/swww
        fi
    else
        echo "NOTE: Install cargo to get swappy, swww, and wallust"
    fi

    # nwg-displays
    if ! command -v nwg-displays &>/dev/null; then
        echo "Installing nwg-displays..."
        sudo apt install -y python3-build python3-installer libgtk-layer-shell-dev gir1.2-gtklayershell-0.1
        sudo ln -sf /usr/bin/python3 /usr/bin/python
        rm -rf /tmp/nwg-displays
        git clone https://github.com/nwg-piotr/nwg-displays /tmp/nwg-displays
        cd /tmp/nwg-displays && sudo ./install.sh
        cd "$DOTFILES_DIR"
        rm -rf /tmp/nwg-displays
    fi

    # nwg-look
    if ! command -v nwg-look &>/dev/null; then
        echo "NOTE: Install nwg-look manually — see https://github.com/nwg-piotr/nwg-look"
    fi

    # Bibata cursor theme
    if [ ! -d "$HOME/.icons/Bibata-Modern-Ice" ]; then
        echo "NOTE: Install Bibata cursor manually:"
        echo "  https://github.com/ful1e5/Bibata_Cursor/releases"
    fi

    # GTK themes
    mkdir -p "$HOME/.themes" "$HOME/.icons"
    echo "NOTE: Install GTK themes if needed:"
    echo "  sudo apt install flat-remix-gtk flat-remix"
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

        # Skip symlinks and files already managed by stow (inside a symlinked dir)
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            local real_path
            real_path="$(readlink -f "$target")"
            case "$real_path" in
                "$DOTFILES_DIR"/*) ;; # Already points into dotfiles repo, skip
                *)
                    local backup_path="$BACKUP_DIR/$pkg/$rel"
                    mkdir -p "$(dirname "$backup_path")"
                    mv "$target" "$backup_path"
                    echo "    backup: $rel"
                    ;;
            esac
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
    kanata wl-kbptr
)

echo "=== Dotfiles installer ==="
echo ""

# Install packages
if [ "$1" != "--no-packages" ]; then
    install_packages
    if [ "$1" = "--hyprland" ]; then
        install_hyprland
    fi
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

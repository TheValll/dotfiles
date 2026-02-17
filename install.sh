#!/usr/bin/env bash
# ============================================================
# Dotfiles installer for fresh Ubuntu
# Installs: nerd-font, zsh, omz, starship, atuin, zoxide,
#           tmux, sesh, lsd, fzf, fd, ripgrep, neovim,
#           lazygit, kitty, rust, python, uv, ROS2 Jazzy
# ============================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[x]${NC} $1"; }
info() { echo -e "${BLUE}[i]${NC} $1"; }

# ============================================================
# Helpers
# ============================================================
cmd_exists() { command -v "$1" &>/dev/null; }

ensure_apt() {
    if ! dpkg -s "$1" &>/dev/null; then
        log "Installing $1..."
        sudo apt-get install -y "$1"
    else
        info "$1 already installed"
    fi
}

# ============================================================
# 0. System update
# ============================================================
log "Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

# ============================================================
# 1. Essential build tools
# ============================================================
log "Installing build essentials..."
sudo apt-get install -y \
    build-essential \
    cmake \
    git \
    curl \
    wget \
    unzip \
    software-properties-common \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv

# ============================================================
# 2. JetBrainsMono Nerd Font
# ============================================================
if ! fc-list | grep -qi "JetBrainsMono Nerd"; then
    log "Installing JetBrainsMono Nerd Font..."
    mkdir -p "$HOME/.local/share/fonts"
    curl -fsSL -o /tmp/jetbrains-nerd.zip \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -o /tmp/jetbrains-nerd.zip -d "$HOME/.local/share/fonts/JetBrainsMono"
    fc-cache -fv
    rm /tmp/jetbrains-nerd.zip
else
    info "JetBrainsMono Nerd Font already installed"
fi

# ============================================================
# 3. Zsh + Oh My Zsh
# ============================================================
log "Installing Zsh..."
ensure_apt zsh

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "Installing Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    info "Oh My Zsh already installed"
fi

# Plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    log "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    log "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Agnosterzak theme
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/themes"
if [ ! -f "$ZSH_CUSTOM/themes/agnosterzak.zsh-theme" ]; then
    log "Installing agnosterzak theme..."
    curl -fsSL -o "$ZSH_CUSTOM/themes/agnosterzak.zsh-theme" \
        https://raw.githubusercontent.com/zakaziko99/agnosterzak-ohmyzsh-theme/master/agnosterzak.zsh-theme
else
    info "agnosterzak theme already installed"
fi

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    log "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
fi

# ============================================================
# 4. Starship prompt
# ============================================================
if ! cmd_exists starship; then
    log "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    info "Starship already installed"
fi

# ============================================================
# 5. Atuin (shell history)
# ============================================================
if ! cmd_exists atuin; then
    log "Installing Atuin..."
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
else
    info "Atuin already installed"
fi

# ============================================================
# 6. Terminal tools: lsd, fzf, fd, ripgrep, zoxide
# ============================================================
log "Installing terminal tools..."

# lsd
if ! cmd_exists lsd; then
    log "Installing lsd..."
    LSD_VERSION=$(curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest | grep -oP '"tag_name": "v?\K[^"]+')
    wget -qO /tmp/lsd.deb "https://github.com/lsd-rs/lsd/releases/latest/download/lsd_${LSD_VERSION}_amd64.deb"
    sudo dpkg -i /tmp/lsd.deb
    rm /tmp/lsd.deb
else
    info "lsd already installed"
fi

# fzf
if ! cmd_exists fzf; then
    log "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all --no-bash --no-fish
    # Ensure fzf-tmux is available in PATH
    if [ -f "$HOME/.fzf/bin/fzf-tmux" ] && [ ! -L "$HOME/.local/bin/fzf-tmux" ]; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$HOME/.fzf/bin/fzf-tmux" "$HOME/.local/bin/fzf-tmux"
    fi
else
    info "fzf already installed"
fi

# fd-find
ensure_apt fd-find
# Create symlink fd -> fdfind
if [ ! -L "$HOME/.local/bin/fd" ] && ! cmd_exists fd; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
fi

# ripgrep
ensure_apt ripgrep

# zoxide
if ! cmd_exists zoxide; then
    log "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
else
    info "zoxide already installed"
fi

# ============================================================
# 7. Tmux + TPM + Sesh
# ============================================================
ensure_apt tmux

# TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    log "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    info "TPM already installed"
fi

# Sesh (tmux session manager)
if ! cmd_exists sesh; then
    log "Installing sesh..."
    SESH_VERSION=$(curl -s https://api.github.com/repos/joshmedeski/sesh/releases/latest | grep -oP '"tag_name": "v?\K[^"]+')
    wget -qO /tmp/sesh.tar.gz "https://github.com/joshmedeski/sesh/releases/latest/download/sesh_Linux_x86_64.tar.gz"
    tar -xzf /tmp/sesh.tar.gz -C /tmp sesh
    sudo mv /tmp/sesh /usr/local/bin/sesh
    rm /tmp/sesh.tar.gz
else
    info "sesh already installed"
fi

# ============================================================
# 8. Kitty terminal
# ============================================================
if ! cmd_exists kitty; then
    log "Installing Kitty..."
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
    # Create desktop integration
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/bin/kitty"
    ln -sf "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/kitten"
    # Desktop file
    mkdir -p "$HOME/.local/share/applications"
    cp "$HOME/.local/kitty.app/share/applications/kitty.desktop" "$HOME/.local/share/applications/"
    sed -i "s|Icon=kitty|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" \
        "$HOME/.local/share/applications/kitty.desktop"
    sed -i "s|Exec=kitty|Exec=$HOME/.local/kitty.app/bin/kitty|g" \
        "$HOME/.local/share/applications/kitty.desktop"
else
    info "Kitty already installed"
fi

# Set Kitty as default terminal
if cmd_exists kitty; then
    log "Setting Kitty as default terminal..."
    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$(which kitty)" 50
    sudo update-alternatives --set x-terminal-emulator "$(which kitty)"
fi

# ============================================================
# 9. Neovim (latest stable from PPA)
# ============================================================
if ! cmd_exists nvim; then
    log "Installing Neovim..."
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt-get update
    sudo apt-get install -y neovim
else
    info "Neovim already installed"
fi

# ============================================================
# 10. Lazygit (via Go)
# ============================================================
if ! cmd_exists lazygit; then
    log "Installing lazygit..."
    if cmd_exists go; then
        go install github.com/jesseduffield/lazygit@latest
    else
        warn "Go not found, installing lazygit from GitHub release..."
        LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -oP '"tag_name": "v?\K[^"]+')
        curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
        sudo install /tmp/lazygit /usr/local/bin
        rm /tmp/lazygit /tmp/lazygit.tar.gz
    fi
else
    info "lazygit already installed"
fi

# ============================================================
# 11. Rust (via rustup)
# ============================================================
if ! cmd_exists rustup; then
    log "Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    info "Rust already installed"
fi

# ============================================================
# 12. Python + UV
# ============================================================
if ! cmd_exists uv; then
    log "Installing UV (Python package manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    info "UV already installed"
fi

# ============================================================
# 13. ROS2 Jazzy
# ============================================================
if [ ! -f /opt/ros/jazzy/setup.zsh ]; then
    log "Installing ROS2 Jazzy..."

    # Prerequisites
    sudo apt-get install -y locales
    sudo locale-gen en_US en_US.UTF-8
    sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
    export LANG=en_US.UTF-8

    # Add ROS2 repo
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y universe
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | \
        sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
    sudo apt-get update

    # Install ROS2 desktop
    sudo apt-get install -y ros-jazzy-desktop ros-dev-tools

    warn "ROS2 Jazzy installed. You may need to adjust the version for your Ubuntu release."
else
    info "ROS2 Jazzy already installed"
fi

# ============================================================
# 14. Deploy dotfiles
# ============================================================
log "Deploying configuration files..."

# Backup existing configs
backup_if_exists() {
    if [ -e "$1" ] && [ ! -L "$1" ]; then
        warn "Backing up existing $1 to $1.bak"
        mv "$1" "$1.bak"
    fi
}

# Zsh
backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.zshenv"
cp "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
cp "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv"

# Tmux
backup_if_exists "$HOME/.tmux.conf"
cp "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# tmux-sesh script
mkdir -p "$HOME/.local/bin"
cp "$DOTFILES_DIR/tmux/tmux-sesh" "$HOME/.local/bin/tmux-sesh"
chmod +x "$HOME/.local/bin/tmux-sesh"

# Kitty
mkdir -p "$HOME/.config/kitty"
backup_if_exists "$HOME/.config/kitty/kitty.conf"
cp "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"

# Starship
mkdir -p "$HOME/.config"
backup_if_exists "$HOME/.config/starship.toml"
cp "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# Atuin
mkdir -p "$HOME/.config/atuin"
backup_if_exists "$HOME/.config/atuin/config.toml"
cp "$DOTFILES_DIR/atuin/config.toml" "$HOME/.config/atuin/config.toml"

# Neovim
backup_if_exists "$HOME/.config/nvim"
mkdir -p "$HOME/.config/nvim/lua/config"
mkdir -p "$HOME/.config/nvim/lua/plugins"
cp "$DOTFILES_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua"
cp "$DOTFILES_DIR/nvim/lua/config/lazy.lua" "$HOME/.config/nvim/lua/config/lazy.lua"
cp "$DOTFILES_DIR/nvim/lua/config/keymaps.lua" "$HOME/.config/nvim/lua/config/keymaps.lua"
cp "$DOTFILES_DIR/nvim/lua/config/options.lua" "$HOME/.config/nvim/lua/config/options.lua"
cp "$DOTFILES_DIR/nvim/lua/config/autocmds.lua" "$HOME/.config/nvim/lua/config/autocmds.lua"
cp "$DOTFILES_DIR/nvim/lua/plugins/mini-files.lua" "$HOME/.config/nvim/lua/plugins/mini-files.lua"
cp "$DOTFILES_DIR/nvim/lua/plugins/ros2.lua" "$HOME/.config/nvim/lua/plugins/ros2.lua"
cp "$DOTFILES_DIR/nvim/lua/plugins/repl.lua" "$HOME/.config/nvim/lua/plugins/repl.lua"
cp "$DOTFILES_DIR/nvim/lua/plugins/snacks.lua" "$HOME/.config/nvim/lua/plugins/snacks.lua"

# ROS2 scripts
cp "$DOTFILES_DIR/scripts/ros2-compile-commands" "$HOME/.local/bin/ros2-compile-commands"
chmod +x "$HOME/.local/bin/ros2-compile-commands"

# ============================================================
# 15. Install Tmux plugins
# ============================================================
log "Installing Tmux plugins via TPM..."
# Start a detached tmux server so TPM can run properly
tmux new-session -d -s _tpm_install 2>/dev/null || true
"$HOME/.tmux/plugins/tpm/bin/install_plugins" || warn "TPM plugin install failed (run prefix+I inside tmux)"
tmux kill-session -t _tpm_install 2>/dev/null || true

# ============================================================
# 16. First Neovim launch (installs lazy.nvim + all plugins)
# ============================================================
log "Installing Neovim plugins (headless)..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || warn "Neovim plugin sync may need a manual :Lazy sync"

# ============================================================
# Done!
# ============================================================
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Installation complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Installed:"
echo "  Shell:     zsh + oh-my-zsh (agnosterzak) + starship + atuin"
echo "  Terminal:  kitty + tmux (tokyonight) + sesh"
echo "  Tools:     lsd, fzf, fd, ripgrep, zoxide, lazygit"
echo "  Editor:    neovim (LazyVim) + mini.files, ros2, python-repl, snacks"
echo "  Languages: rust (rustup), python3 + uv"
echo "  Robotics:  ROS2 Jazzy"
echo ""
echo "Next steps:"
echo "  1. Log out and log back in (or run: exec zsh)"
echo "  2. Open tmux and press Ctrl+a then I to install tmux plugins"
echo "  3. Open nvim to verify all plugins loaded correctly"
echo "  4. JetBrainsMono Nerd Font is installed automatically"
echo ""

# ============================================
# Tools & Runtime Initialization
# ============================================

# Starship prompt
eval "$(starship init zsh)"

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Atuin (shell history search)
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# NVM (Node version manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ROS2 Jazzy
source /opt/ros/jazzy/setup.zsh

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

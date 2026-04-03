# ============================================
# .zshrc - Main loader
# Fichiers modulaires dans ~/.config/zsh/
# ============================================

# Oh-My-Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnosterzak"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Secrets (~/.secret contient API keys + git profile)
[ -f "$HOME/.secret" ] && source "$HOME/.secret"

# Git user from .secret
if [ -n "$GIT_USER_NAME" ]; then
  git config --global user.name "$GIT_USER_NAME"
  git config --global user.email "$GIT_USER_EMAIL"
fi

# Load modular configs
for conf in "$HOME/.config/zsh/"*.zsh; do
  [ -f "$conf" ] && source "$conf"
done

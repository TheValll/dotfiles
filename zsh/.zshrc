# ============================================
# Oh My Zsh
# ============================================
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnosterzak"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# ============================================
# Sesh (tmux session manager)
# ============================================
function sesh_connect() {
  sesh connect $(
        sesh list | fzf-tmux -p 55%,60% \
                --no-sort --border-label ' sesh ' --prompt '  ' \
                --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
                --bind 'tab:down,btab:up' \
                --bind 'ctrl-a:change-prompt(  )+reload(sesh list)' \
                --bind 'ctrl-t:change-prompt(  )+reload(sesh list -t)' \
                --bind 'ctrl-g:change-prompt(  )+reload(sesh list -c)' \
                --bind 'ctrl-x:change-prompt(  )+reload(sesh list -z)' \
                --bind 'ctrl-f:change-prompt(  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
                --bind 'ctrl-d:execute(tmux kill-session -t {})+change-prompt(  )+reload(sesh list)'
)
}

alias s=sesh_connect

# ============================================
# Aliases
# ============================================
# lsd (modern ls)
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# ============================================
# PATH
# ============================================
. "$HOME/.local/bin/env"
export PATH="$HOME/.local/bin:$PATH"

# ============================================
# Starship prompt
# ============================================
eval "$(starship init zsh)"

# ============================================
# Atuin (shell history)
# ============================================
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# ============================================
# ROS2 Jazzy
# ============================================
source /opt/ros/jazzy/setup.zsh
alias cbuild='colcon build && ros2-compile-commands .'

# ============================================
# Aliases
# ============================================

# Filesystem (lsd)
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# Kubernetes
alias k="kubectl"
alias kx="kubectx"
alias kn="kubens"

# Editors & tools
alias v="nvim"
alias c="clear"

# Git
alias gss="git status"
alias gm="git commit -m"

# ROS2
alias cbuild='colcon build && ros2-compile-commands .'
alias ros2x='QT_QPA_PLATFORM=xcb ros2'

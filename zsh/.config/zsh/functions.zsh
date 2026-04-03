# ============================================
# Functions
# ============================================

# Sesh - tmux session manager avec fzf
# Ctrl+a: all | Ctrl+t: tmux | Ctrl+g: configs
# Ctrl+x: zoxide | Ctrl+d: kill | Ctrl+f: find
function sesh_connect() {
  sesh connect $(
    sesh list | fzf-tmux -p 55%,60% \
      --no-sort --border-label ' sesh ' --prompt '⚡  ' \
      --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
      --bind 'tab:down,btab:up' \
      --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list)' \
      --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t)' \
      --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c)' \
      --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z)' \
      --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
      --bind 'ctrl-d:execute(tmux kill-session -t {})+change-prompt(⚡  )+reload(sesh list)'
  )
}
alias s=sesh_connect

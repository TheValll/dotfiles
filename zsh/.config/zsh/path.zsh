# ============================================
# PATH & Environment
# ============================================

. "$HOME/.local/bin/env"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Kubernetes (auto-detect kubeconfigs)
export KUBECONFIG=$KUBECONFIG:$(find ~/.kube/ -iname "kubeconfig*" 2>/dev/null | tr "\n" ":")

#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_SRC="$REPO_DIR/home"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*"; }

# 1. Xcode CLT
if ! xcode-select -p &>/dev/null; then
  log "Installing Xcode Command Line Tools..."
  xcode-select --install || true
  warn "Re-run setup.sh once the Xcode CLT installer finishes."
  exit 0
fi

# 2. Homebrew
if ! command -v brew &>/dev/null; then
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# 3. Brewfile
log "Running brew bundle..."
if ! brew bundle --file="$REPO_DIR/Brewfile"; then
  warn "brew bundle had failures. Re-run from an interactive terminal to retry."
fi

# 4. fzf key bindings (don't let it touch our .zshrc — we own that)
if [[ -f "$(brew --prefix)/opt/fzf/install" ]]; then
  log "Installing fzf key bindings..."
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc >/dev/null
fi

# 5. Symlink dotfiles
link() {
  local rel="$1"
  local src="$HOME_SRC/$rel"
  local dst="$HOME/$rel"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
      return 0   # already correct
    fi
    if [[ ! -L "$dst" ]]; then
      mv "$dst" "$dst.backup-$(date +%s)"
    fi
  fi
  ln -sfn "$src" "$dst"
  echo "  linked ~/$rel"
}

log "Symlinking dotfiles..."
link .zshrc
link .zprofile
link .gitconfig
link .config/ghostty/config
link .config/gh/config.yml
link .config/starship.toml
link "Library/Application Support/eza/theme.yml"
link .ssh/config

# SSH dir perms (sshd refuses loose perms; config.d holds per-key Host blocks)
mkdir -p "$HOME/.ssh/config.d"
chmod 700 "$HOME/.ssh" "$HOME/.ssh/config.d"

# 6. Git identity (~/.gitconfig.local — gitignored, included by main .gitconfig)
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  log "Configuring git identity..."
  read -r -p "  Git user.name:  " git_name
  read -r -p "  Git user.email: " git_email
  cat > "$HOME/.gitconfig.local" <<EOF
[user]
	name = $git_name
	email = $git_email
EOF
  echo "  wrote ~/.gitconfig.local"
fi

# 7. fnm + Node LTS
if command -v fnm &>/dev/null; then
  log "Installing latest Node LTS via fnm..."
  eval "$(fnm env --use-on-cd)"
  fnm install --lts
fi

# 8. VS Code extensions
if command -v code &>/dev/null; then
  log "Installing VS Code extensions..."
  code --install-extension github.copilot-chat --force >/dev/null || true
else
  warn "'code' CLI not on PATH. Open VS Code → Cmd+Shift+P → 'Shell Command: Install code command in PATH'"
fi

# 9. Fix /opt/homebrew/share perms (silences the recurring compaudit warning from new shells)
if [[ -d /opt/homebrew/share ]]; then
  chmod g-w,o-w /opt/homebrew/share 2>/dev/null || true
fi

log "Done. Run 'exec zsh' to reload your shell."

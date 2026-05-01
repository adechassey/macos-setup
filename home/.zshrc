# PATH
export PATH="$HOME/.local/bin:$PATH"

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_VERIFY EXTENDED_HISTORY

# Type a directory name to cd into it (no need for `cd`)
setopt AUTO_CD

# Completions
FPATH=/opt/homebrew/share/zsh-completions:$FPATH
autoload -Uz compinit && compinit

# Plugins
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# fnm (Node version manager)
if command -v fnm &>/dev/null; then
  eval "$(fnm env --use-on-cd)"
fi

# Personal aliases
alias cd="z"
alias pn="pnpm"
alias cl="claude"
alias c="code ."
alias ..="cd .."
alias ...="cd ../.."

# ls aliases (eza)
export EZA_ICONS_AUTO=always
alias ls='eza'
alias l='eza -l --git'
alias ll='eza -la --git'
alias lt='eza --tree --level=2'
alias ldot='eza -ld .*'

# Git aliases (curated from oh-my-zsh git plugin)
# status / log
alias gst='git status'
alias gss='git status -s'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
# add / commit
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gca='git commit -v -a'
alias gcam='git commit -a -m'
alias gcan='git commit --amend --no-edit'
# branch / checkout
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
# diff
alias gd='git diff'
alias gds='git diff --staged'
# push / pull / fetch
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git pull'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
# merge / rebase
alias gm='git merge'
alias grb='git rebase'
alias grbi='git rebase -i'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
# reset
alias grh='git reset'
alias grhh='git reset --hard'
# stash
alias gsta='git stash push'
alias gstp='git stash pop'
alias gstl='git stash list'
# cherry-pick
alias gcp='git cherry-pick'

# fzf
source <(fzf --zsh)

# Starship prompt
eval "$(starship init zsh)"

# zoxide (smart cd)
eval "$(zoxide init zsh)"

# Per-machine overrides (gitignored)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

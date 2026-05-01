# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal macOS dotfiles + bootstrap for a fresh MacBook. There is no build, no test suite, no lint step. The "code" is shell scripts and config files. Changes are validated by re-running `setup.sh` and using the shell.

**This is a public repository meant to be reused by others.** Two implications when editing:

- **No sensitive information** — names, emails, hostnames, tokens, internal URLs, project-specific identifiers, SSH key contents, etc. Anything machine- or identity-specific belongs in the gitignored local layer (`~/.gitconfig.local`, `~/.ssh/config.d/*`, `~/.config/gh/hosts.yml`). If you're tempted to hardcode a value, ask whether it should be a prompt in `setup.sh` or a local override instead.
- **Avoid overly opinionated config** — settings should be defaults a typical macOS dev would accept, not personal quirks. Highly subjective tweaks (custom keybindings, exotic prompt formats, project-specific env vars) push the repo away from "reusable starter" toward "dotfiles only the author wants." When in doubt, leave it out or make it opt-in.

When unsure whether something counts as sensitive or too opinionated, ask the user before committing it rather than guessing.

## The symlink model (most important thing to understand)

`setup.sh` symlinks files from `home/` in this repo into `$HOME`. After bootstrap, `~/.zshrc`, `~/.gitconfig`, `~/.ssh/config`, etc. are **symlinks pointing back into this repo**.

Consequence: **edit files under `home/` in this repo, never the symlinked copies in `$HOME`**. Edits take effect immediately on the source machine — no re-run of `setup.sh` is needed for config changes. Re-run `setup.sh` only when you've added a new file to symlink, a new Brew package, or want to verify idempotency.

If you find yourself wanting to edit `~/.zshrc`, stop and edit `home/.zshrc` instead.

The `link()` function in `setup.sh` (lines 38–53) is the symlink machinery. It backs up any pre-existing real file to `<dst>.backup-<timestamp>` before linking. The list of linked paths lives in lines 56–63 — adding a new dotfile means dropping it under `home/` AND adding a `link` call there.

## Layered config (what's in the repo vs. machine-local)

Two configs are deliberately split into a tracked layer + a gitignored local layer:

- **Git identity**: `home/.gitconfig` has generic settings and `[include] path = ~/.gitconfig.local`. The `.local` file holds `user.name` / `user.email` and is generated interactively by `setup.sh` on first run (gitignored).
- **SSH**: `home/.ssh/config` has global defaults (`AddKeysToAgent`, `UseKeychain`) and `Include config.d/*`. Per-key `Host` blocks live in `~/.ssh/config.d/<name>` and are **not** in the repo — they're created by `bin/new-ssh-key`, which generates an ed25519 key, writes the config.d block, and adds the key to the macOS Keychain.

For multiple GitHub accounts, `bin/new-ssh-key` supports an alias pattern: use a Host like `github.com-work` with `HostName github.com` so the alias resolves to the real host but uses a distinct key.

## Bootstrap flow (`setup.sh`)

Idempotent. Order matters — each step assumes the previous succeeded:

1. Xcode CLT (exits early if missing — installer is async, user must re-run)
2. Homebrew install + `brew shellenv` eval
3. `brew bundle` against `Brewfile`
4. fzf key bindings via `$(brew --prefix)/opt/fzf/install` with `--no-update-rc` (we own `.zshrc`, fzf must not touch it)
5. Symlink dotfiles from `home/` → `$HOME`
6. Generate `~/.gitconfig.local` if missing (interactive prompt)
7. `fnm install --lts`
8. VS Code extensions (`code --install-extension ...`)
9. `chmod g-w,o-w /opt/homebrew/share` to silence the recurring `compaudit` warning

## Adding things

- **New CLI tool / app**: add to `Brewfile`, then `brew bundle install` (or re-run `setup.sh`).
- **New dotfile**: drop it under `home/` mirroring its `$HOME` path, then add a `link "<rel-path>"` call in `setup.sh`.
- **New SSH key**: run `bin/new-ssh-key` — do not hand-edit `~/.ssh/config`.

## Conventions worth preserving

- `home/.zshrc` is the single source of truth for shell config. Plugin sourcing, aliases, fnm/fzf/starship/zoxide init all live there in a specific order (completions before plugins; starship/zoxide after fnm). Don't let other installers append to it.
- Aliases in `.zshrc` are grouped and curated (git block is the oh-my-zsh subset the user actually uses) — match the existing grouping when adding more.
- `cd` is aliased to `z` (zoxide). When suggesting shell snippets, remember plain `cd` still works but the user-installed alias rewires it.

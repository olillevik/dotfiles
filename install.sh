#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SKILLS_DIR="$SCRIPT_DIR/skills"
SOURCE_HOOKS_DIR="$SCRIPT_DIR/hooks/git"
SOURCE_COMMIT_MSG_HOOK="$SOURCE_HOOKS_DIR/commit-msg"
GLOBAL_HOOKS_DIR="$HOME/.git-templates/hooks"
TARGET_COMMIT_MSG_HOOK="$GLOBAL_HOOKS_DIR/commit-msg"

if [[ ! -d "$SOURCE_SKILLS_DIR" ]]; then
  printf 'Expected skills directory at %s\n' "$SOURCE_SKILLS_DIR" >&2
  exit 1
fi

if [[ ! -f "$SOURCE_COMMIT_MSG_HOOK" ]]; then
  printf 'Expected git commit-msg hook at %s\n' "$SOURCE_COMMIT_MSG_HOOK" >&2
  exit 1
fi

TARGETS=(
  "$HOME/.copilot/skills"
  "$HOME/.claude/skills"
)

link_skills_dir() {
  local target="$1"
  local parent
  parent="$(dirname "$target")"

  mkdir -p "$parent"

  if [[ -L "$target" ]]; then
    local current
    current="$(readlink "$target")"
    if [[ "$current" == "$SOURCE_SKILLS_DIR" ]]; then
      printf 'Already linked: %s -> %s\n' "$target" "$SOURCE_SKILLS_DIR"
      return
    fi

    rm "$target"
  elif [[ -e "$target" ]]; then
    printf 'Refusing to replace existing non-symlink path: %s\n' "$target" >&2
    printf 'Move it away or remove it, then rerun install.sh\n' >&2
    exit 1
  fi

  ln -s "$SOURCE_SKILLS_DIR" "$target"
  printf 'Linked: %s -> %s\n' "$target" "$SOURCE_SKILLS_DIR"
}

ensure_global_hooks_path() {
  local current
  current="$(git config --global --get core.hooksPath || true)"

  if [[ -z "$current" ]]; then
    git config --global core.hooksPath "$GLOBAL_HOOKS_DIR"
    printf 'Configured git core.hooksPath: %s\n' "$GLOBAL_HOOKS_DIR"
    return
  fi

  if [[ "$current" != "$GLOBAL_HOOKS_DIR" ]]; then
    printf 'Refusing to replace existing global core.hooksPath: %s\n' "$current" >&2
    printf 'Set it to %s yourself or move the existing hooks, then rerun install.sh\n' "$GLOBAL_HOOKS_DIR" >&2
    exit 1
  fi

  printf 'Using existing git core.hooksPath: %s\n' "$GLOBAL_HOOKS_DIR"
}

link_commit_msg_hook() {
  mkdir -p "$GLOBAL_HOOKS_DIR"

  if [[ -L "$TARGET_COMMIT_MSG_HOOK" ]]; then
    local current
    current="$(readlink "$TARGET_COMMIT_MSG_HOOK")"
    if [[ "$current" == "$SOURCE_COMMIT_MSG_HOOK" ]]; then
      printf 'Already linked: %s -> %s\n' "$TARGET_COMMIT_MSG_HOOK" "$SOURCE_COMMIT_MSG_HOOK"
      return
    fi

    rm "$TARGET_COMMIT_MSG_HOOK"
  elif [[ -e "$TARGET_COMMIT_MSG_HOOK" ]]; then
    if cmp -s "$SOURCE_COMMIT_MSG_HOOK" "$TARGET_COMMIT_MSG_HOOK"; then
      rm "$TARGET_COMMIT_MSG_HOOK"
    else
      printf 'Refusing to replace existing non-matching hook: %s\n' "$TARGET_COMMIT_MSG_HOOK" >&2
      printf 'Move it away or update it manually, then rerun install.sh\n' >&2
      exit 1
    fi
  fi

  ln -s "$SOURCE_COMMIT_MSG_HOOK" "$TARGET_COMMIT_MSG_HOOK"
  printf 'Linked: %s -> %s\n' "$TARGET_COMMIT_MSG_HOOK" "$SOURCE_COMMIT_MSG_HOOK"
}

for target in "${TARGETS[@]}"; do
  link_skills_dir "$target"
done

ensure_global_hooks_path
link_commit_msg_hook

printf '\nInstall complete. Restart your agent tools or start a new session to pick up the shared skills.\n'

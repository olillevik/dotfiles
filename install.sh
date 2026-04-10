#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SKILLS_DIR="$SCRIPT_DIR/skills"

if [[ ! -d "$SOURCE_SKILLS_DIR" ]]; then
  printf 'Expected skills directory at %s\n' "$SOURCE_SKILLS_DIR" >&2
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

for target in "${TARGETS[@]}"; do
  link_skills_dir "$target"
done

printf '\nInstall complete. Restart your agent tools or start a new session to pick up the shared skills.\n'

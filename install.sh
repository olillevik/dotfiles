#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SKILLS_DIR="$SCRIPT_DIR/skills"
SOURCE_HOOKS_DIR="$SCRIPT_DIR/hooks/git"
SOURCE_COMMIT_MSG_HOOK="$SOURCE_HOOKS_DIR/commit-msg"
GLOBAL_HOOKS_DIR="$HOME/.git-templates/hooks"
TARGET_COMMIT_MSG_HOOK="$GLOBAL_HOOKS_DIR/commit-msg"
MATTPOCOCK_SKILLS_DIR="$HOME/.mattpocock-skills"

if [[ ! -d "$SOURCE_SKILLS_DIR" ]]; then
  printf 'Expected skills directory at %s\n' "$SOURCE_SKILLS_DIR" >&2
  exit 1
fi

if [[ ! -f "$SOURCE_COMMIT_MSG_HOOK" ]]; then
  printf 'Expected git commit-msg hook at %s\n' "$SOURCE_COMMIT_MSG_HOOK" >&2
  exit 1
fi

SKILL_TARGETS=(
  "$HOME/.copilot/skills"
  "$HOME/.claude/skills"
)

sync_mattpocock_skills() {
  if [[ -d "$MATTPOCOCK_SKILLS_DIR/.git" ]]; then
    printf 'Updating mattpocock/skills at %s\n' "$MATTPOCOCK_SKILLS_DIR"
    git -C "$MATTPOCOCK_SKILLS_DIR" pull --ff-only
  else
    printf 'Cloning mattpocock/skills to %s\n' "$MATTPOCOCK_SKILLS_DIR"
    git clone --depth=1 https://github.com/mattpocock/skills.git "$MATTPOCOCK_SKILLS_DIR"
  fi
}

link_skill_into() {
  local skill_src="$1"
  local target_dir="$2"
  local name
  name="$(basename "$skill_src")"
  local target="$target_dir/$name"

  if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
    local backup="${target}.backup.$(date +%s)"
    printf 'Backing up existing path: %s -> %s\n' "$target" "$backup"
    mv "$target" "$backup"
  fi

  ln -sfn "$skill_src" "$target"
  printf '  linked %s\n' "$name"
}

link_all_skills() {
  local target_dir="$1"
  local parent
  parent="$(dirname "$target_dir")"
  mkdir -p "$parent"

  # If target is an old whole-directory symlink, remove it so we can make a real dir
  if [[ -L "$target_dir" ]]; then
    rm "$target_dir"
  fi
  mkdir -p "$target_dir"

  printf 'Linking local skills into %s\n' "$target_dir"
  while IFS= read -r -d '' skill_md; do
    link_skill_into "$(dirname "$skill_md")" "$target_dir"
  done < <(find "$SOURCE_SKILLS_DIR" -maxdepth 2 -name SKILL.md -print0)

  printf 'Linking mattpocock skills into %s\n' "$target_dir"
  while IFS= read -r -d '' skill_md; do
    local skill_dir
    skill_dir="$(dirname "$skill_md")"
    # Skip deprecated and in-progress categories
    case "$skill_dir" in
      *deprecated*|*in-progress*) continue ;;
    esac
    link_skill_into "$skill_dir" "$target_dir"
  done < <(find "$MATTPOCOCK_SKILLS_DIR/skills" -name SKILL.md -print0)
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

sync_mattpocock_skills

for target in "${SKILL_TARGETS[@]}"; do
  link_all_skills "$target"
done

ensure_global_hooks_path
link_commit_msg_hook

printf '\nInstall complete. Restart your agent tools or start a new session to pick up the shared skills.\n'

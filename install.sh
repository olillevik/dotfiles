#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SKILLS_DIR="$SCRIPT_DIR/skills"
SOURCE_HOOKS_DIR="$SCRIPT_DIR/hooks/git"
SOURCE_COMMIT_MSG_HOOK="$SOURCE_HOOKS_DIR/commit-msg"
SOURCE_AGENTS_MD="$SCRIPT_DIR/AGENTS.md"
SOURCE_MINIMALIST_MD="$SCRIPT_DIR/minimalist-engineering.md"
GLOBAL_HOOKS_DIR="$HOME/.git-templates/hooks"
TARGET_COMMIT_MSG_HOOK="$GLOBAL_HOOKS_DIR/commit-msg"
MATTPOCOCK_SKILLS_DIR="$HOME/.mattpocock-skills"

if [[ ! -d "$SOURCE_SKILLS_DIR" ]]; then
  printf 'Expected skills directory at %s\n' "$SOURCE_SKILLS_DIR" >&2
  exit 1
fi

if [[ ! -f "$SOURCE_AGENTS_MD" ]]; then
  printf 'Expected instruction file at %s\n' "$SOURCE_AGENTS_MD" >&2
  exit 1
fi

if [[ ! -f "$SOURCE_COMMIT_MSG_HOOK" ]]; then
  printf 'Expected git commit-msg hook at %s\n' "$SOURCE_COMMIT_MSG_HOOK" >&2
  exit 1
fi

if [[ ! -f "$SOURCE_MINIMALIST_MD" ]]; then
  printf 'Expected principles file at %s\n' "$SOURCE_MINIMALIST_MD" >&2
  exit 1
fi

SKILL_TARGETS=(
  "$HOME/.copilot/skills"
  "$HOME/.claude/skills"
)

# Both names point at the same file. Claude Code reads CLAUDE.md, other agents read AGENTS.md.
INSTRUCTION_TARGETS=(
  "$HOME/.claude/AGENTS.md"
  "$HOME/.claude/CLAUDE.md"
  "$HOME/.copilot/AGENTS.md"
)

# AGENTS.md points agents at this path, so both tools resolve it there.
MINIMALIST_TARGET="$HOME/.claude/minimalist-engineering.md"

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

  # Everything here is a copy of something in git. Replace it.
  if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
    printf 'Replacing existing path: %s\n' "$target"
    rm -rf "$target"
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

  # Upstream renames and deletions leave symlinks pointing at nothing.
  local dead
  while IFS= read -r -d '' dead; do
    printf 'Removing dead symlink: %s\n' "$dead"
    rm "$dead"
  done < <(find "$target_dir" -maxdepth 1 -type l ! -exec test -e {} \; -print0)

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

link_instructions() {
  local target
  for target in "${INSTRUCTION_TARGETS[@]}"; do
    mkdir -p "$(dirname "$target")"

    if [[ -L "$target" ]]; then
      if [[ "$(readlink "$target")" == "$SOURCE_AGENTS_MD" ]]; then
        printf 'Already linked: %s -> %s\n' "$target" "$SOURCE_AGENTS_MD"
        continue
      fi
      rm "$target"
    elif [[ -e "$target" ]]; then
      printf 'Replacing existing file: %s\n' "$target"
      rm -rf "$target"
    fi

    ln -s "$SOURCE_AGENTS_MD" "$target"
    printf 'Linked: %s -> %s\n' "$target" "$SOURCE_AGENTS_MD"
  done
}

link_minimalist_principles() {
  mkdir -p "$(dirname "$MINIMALIST_TARGET")"

  if [[ -L "$MINIMALIST_TARGET" ]]; then
    if [[ "$(readlink "$MINIMALIST_TARGET")" == "$SOURCE_MINIMALIST_MD" ]]; then
      printf 'Already linked: %s -> %s\n' "$MINIMALIST_TARGET" "$SOURCE_MINIMALIST_MD"
      return
    fi
    rm "$MINIMALIST_TARGET"
  elif [[ -e "$MINIMALIST_TARGET" ]]; then
    printf 'Replacing existing file: %s\n' "$MINIMALIST_TARGET"
    rm -rf "$MINIMALIST_TARGET"
  fi

  ln -s "$SOURCE_MINIMALIST_MD" "$MINIMALIST_TARGET"
  printf 'Linked: %s -> %s\n' "$MINIMALIST_TARGET" "$SOURCE_MINIMALIST_MD"
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

link_instructions
link_minimalist_principles

ensure_global_hooks_path
link_commit_msg_hook

printf '\nInstall complete. Restart your agent tools or start a new session to pick up the shared skills.\n'

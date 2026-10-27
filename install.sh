#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARKETPLACE_NAME=dotfiles
PLUGIN_NAME=my-plugin
PLUGIN_DIR="$SCRIPT_DIR/plugins/$PLUGIN_NAME"
SOURCE_SKILLS_DIR="$PLUGIN_DIR/skills"
SOURCE_HOOKS_DIR="$SCRIPT_DIR/hooks/git"
SOURCE_COMMIT_MSG_HOOK="$SOURCE_HOOKS_DIR/commit-msg"
SOURCE_AGENTS_MD="$SCRIPT_DIR/AGENTS.md"
GLOBAL_HOOKS_DIR="$HOME/.git-templates/hooks"
TARGET_COMMIT_MSG_HOOK="$GLOBAL_HOOKS_DIR/commit-msg"
OLD_MATTPOCOCK_SKILLS_DIR="$HOME/.mattpocock-skills"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
COPILOT_SKILLS_DIR="$HOME/.copilot/skills"

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

# Both names point at the same file. Claude Code reads CLAUDE.md, other agents read AGENTS.md.
INSTRUCTION_TARGETS=(
  "$HOME/.claude/AGENTS.md"
  "$HOME/.claude/CLAUDE.md"
  "$HOME/.copilot/AGENTS.md"
)

# Remove links that earlier versions of this installer created: links into this repo, links into
# the old mattpocock clone, and links that no longer resolve. Links to other sources stay.
clean_old_links() {
  local dir="$1"
  local link target

  [[ -d "$dir" ]] || return 0

  for link in "$dir"/*; do
    [[ -L "$link" ]] || continue
    target="$(readlink "$link")"
    case "$target" in
      "$SCRIPT_DIR"/*|"$OLD_MATTPOCOCK_SKILLS_DIR"/*)
        printf 'Removing link: %s\n' "$link"
        rm "$link"
        ;;
      *)
        if [[ ! -e "$link" ]]; then
          printf 'Removing dead link: %s\n' "$link"
          rm "$link"
        fi
        ;;
    esac
  done
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

link_copilot_skills() {
  local skill_dir

  mkdir -p "$COPILOT_SKILLS_DIR"
  clean_old_links "$COPILOT_SKILLS_DIR"

  printf 'Linking plugin skills into %s\n' "$COPILOT_SKILLS_DIR"
  for skill_dir in "$SOURCE_SKILLS_DIR"/*/; do
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    link_skill_into "${skill_dir%/}" "$COPILOT_SKILLS_DIR"
  done
}

register_claude_plugin() {
  if ! command -v claude >/dev/null 2>&1; then
    printf 'claude not found, skipping the Claude Code plugin\n' >&2
    return 0
  fi

  printf 'Registering %s with Claude Code\n' "$SCRIPT_DIR"
  claude plugin marketplace add "$SCRIPT_DIR"
  claude plugin install "$PLUGIN_NAME@$MARKETPLACE_NAME"
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

clean_old_links "$CLAUDE_SKILLS_DIR"
register_claude_plugin
link_copilot_skills

link_instructions

ensure_global_hooks_path
link_commit_msg_hook

printf '\nInstall complete. Restart your agent tools or start a new session to pick up the skills.\n'

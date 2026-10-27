#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="$REPO_DIR/plugins/my-plugin"

UPSTREAM_NAME=""
REQUESTED_SHA=""
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    *)
      if [[ -z "$UPSTREAM_NAME" ]]; then
        UPSTREAM_NAME="$1"
      else
        REQUESTED_SHA="$1"
      fi
      ;;
  esac
  shift
done

if [[ -z "$UPSTREAM_NAME" ]]; then
  printf 'Usage: scripts/update-upstream.sh <upstream-folder> [--dry-run] [<sha>]\n' >&2
  exit 1
fi

UPSTREAM_DIR="$PLUGIN_DIR/$UPSTREAM_NAME"
PIN_FILE="$UPSTREAM_DIR/PIN.md"

if [[ ! -f "$PIN_FILE" ]]; then
  printf 'Expected pin file at %s\n' "$PIN_FILE" >&2
  exit 1
fi

UPSTREAM_URL="$(awk -F': ' '$1 == "Upstream" { print $2 }' "$PIN_FILE")"
CURRENT_SHA="$(awk -F': ' '$1 == "Commit" { print $2 }' "$PIN_FILE")"
if [[ -z "$UPSTREAM_URL" || -z "$CURRENT_SHA" ]]; then
  printf 'Expected Upstream and Commit lines in %s\n' "$PIN_FILE" >&2
  exit 1
fi
REPO_SLUG="${UPSTREAM_URL#https://github.com/}"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

git clone --quiet "$UPSTREAM_URL.git" "$WORK_DIR/upstream"

if [[ -n "$REQUESTED_SHA" ]]; then
  TARGET_SHA="$(git -C "$WORK_DIR/upstream" rev-parse --verify "$REQUESTED_SHA^{commit}")"
else
  TARGET_SHA="$(git -C "$WORK_DIR/upstream" rev-parse origin/HEAD)"
fi

if [[ "$TARGET_SHA" == "$CURRENT_SHA" ]]; then
  printf 'Already pinned to %s. Nothing to do.\n' "$CURRENT_SHA"
  exit 0
fi

SHORT_SHA="${TARGET_SHA:0:7}"
git -C "$WORK_DIR/upstream" checkout --quiet --detach "$TARGET_SHA"

# A linked skill is a symlink in plugins/my-plugin/skills that points into this copy, for example
# skills/tdd -> ../upstream-mattpocock/skills/engineering/tdd. The part after the copy folder is the path upstream.
LINKED_FILE="$WORK_DIR/linked.txt"
: > "$LINKED_FILE"
for link in "$PLUGIN_DIR"/skills/*; do
  [[ -L "$link" ]] || continue
  target="$(readlink "$link")"
  case "$target" in
    "../$UPSTREAM_NAME/"*) printf '%s\n' "${target#../$UPSTREAM_NAME/}" >> "$LINKED_FILE" ;;
  esac
done

if [[ ! -s "$LINKED_FILE" ]]; then
  printf 'No skill links point into %s\n' "$UPSTREAM_NAME" >&2
  exit 1
fi

while read -r path; do
  if [[ ! -f "$WORK_DIR/upstream/$path/SKILL.md" ]]; then
    printf 'Upstream %s has no %s/SKILL.md\n' "$SHORT_SHA" "$path" >&2
    exit 1
  fi
done < "$LINKED_FILE"

# Skills beside a linked skill that are new since the pin and have no link. They are listed in the PR and not copied.
NEW_FILE="$WORK_DIR/new.txt"
: > "$NEW_FILE"
while read -r parent; do
  names="$(git -C "$WORK_DIR/upstream" ls-tree -d --name-only "$TARGET_SHA:$parent" 2>/dev/null || true)"
  while read -r name; do
    [[ -n "$name" ]] || continue
    path="$parent/$name"
    if grep -qx "$path" "$LINKED_FILE"; then continue; fi
    if ! git -C "$WORK_DIR/upstream" cat-file -e "$TARGET_SHA:$path/SKILL.md" 2>/dev/null; then continue; fi
    if git -C "$WORK_DIR/upstream" cat-file -e "$CURRENT_SHA:$path/SKILL.md" 2>/dev/null; then continue; fi
    printf '%s\n' "$path" >> "$NEW_FILE"
  done <<< "$names"
done < <(sed 's|/[^/]*$||' "$LINKED_FILE" | sort -u)

if [[ -n "$(git -C "$REPO_DIR" status --porcelain -- "$UPSTREAM_DIR")" ]]; then
  printf 'Local changes under %s. Commit or discard them first.\n' "$UPSTREAM_DIR" >&2
  exit 1
fi

if [[ "$DRY_RUN" -eq 0 ]]; then
  if [[ "$(git -C "$REPO_DIR" rev-parse --abbrev-ref HEAD)" != "main" ]]; then
    printf 'Run from main, so the PR starts from main.\n' >&2
    exit 1
  fi
  if [[ -n "$(git -C "$REPO_DIR" status --porcelain)" ]]; then
    printf 'The working tree has local changes. Commit or stash them first.\n' >&2
    exit 1
  fi
  BRANCH="update-$UPSTREAM_NAME-$SHORT_SHA"
  git -C "$REPO_DIR" switch --quiet -c "$BRANCH"
fi

find "$UPSTREAM_DIR" -mindepth 1 -maxdepth 1 ! -name PIN.md ! -name LICENSE -exec rm -rf {} +
while read -r path; do
  mkdir -p "$UPSTREAM_DIR/$(dirname "$path")"
  cp -R "$WORK_DIR/upstream/$path" "$UPSTREAM_DIR/$(dirname "$path")/"
done < "$LINKED_FILE"
cp "$WORK_DIR/upstream/LICENSE" "$UPSTREAM_DIR/LICENSE"

COMMITTED="$(git -C "$WORK_DIR/upstream" show -s --format=%cI "$TARGET_SHA")"
printf 'Upstream: %s\nCommit: %s\nCommitted: %s\n\nFiles under this folder are copied from the commit above by scripts/update-upstream.sh.\nDo not edit them by hand.\n' "$UPSTREAM_URL" "$TARGET_SHA" "$COMMITTED" > "$PIN_FILE"

for link in "$PLUGIN_DIR"/skills/*; do
  [[ -L "$link" ]] || continue
  if [[ ! -e "$link" ]]; then
    printf 'Broken link: %s\n' "$link" >&2
    exit 1
  fi
done

if command -v claude >/dev/null 2>&1; then
  if ! VALIDATE_OUTPUT="$(claude plugin validate "$PLUGIN_DIR" 2>&1)"; then
    printf '%s\n' "$VALIDATE_OUTPUT" >&2
    exit 1
  fi
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  printf 'Dry run: %s to %s. Nothing committed.\n' "${CURRENT_SHA:0:7}" "$SHORT_SHA"
  git -C "$REPO_DIR" status --short -- "$UPSTREAM_DIR"
  exit 0
fi

git -C "$REPO_DIR" add -A -- "$UPSTREAM_DIR"
git -C "$REPO_DIR" commit --quiet -m "Update $REPO_SLUG to $SHORT_SHA"
git -C "$REPO_DIR" push --quiet -u origin "$BRANCH"

BODY_FILE="$WORK_DIR/pr-body.md"
{
  printf 'Moves the copy of %s in %s from %s to %s.\n\n' "$REPO_SLUG" "$UPSTREAM_NAME" "${CURRENT_SHA:0:7}" "$SHORT_SHA"
  printf 'Compare upstream: %s/compare/%s...%s\n\n' "$UPSTREAM_URL" "$CURRENT_SHA" "$TARGET_SHA"
  printf 'Upstream commits that touch the copied skills:\n\n'
  git -C "$WORK_DIR/upstream" log --format='- %h %s' "$CURRENT_SHA..$TARGET_SHA" -- $(cat "$LINKED_FILE")
  printf '\nNew upstream skills in the same folders, not copied:\n\n'
  if [[ -s "$NEW_FILE" ]]; then
    sed 's/^/- /' "$NEW_FILE"
  else
    printf 'None.\n'
  fi
  printf '\nThe Files tab shows every changed file under plugins/my-plugin/%s/.\n' "$UPSTREAM_NAME"
} > "$BODY_FILE"

gh pr create --base main --head "$BRANCH" --title "Update $REPO_SLUG to $SHORT_SHA" --body-file "$BODY_FILE"

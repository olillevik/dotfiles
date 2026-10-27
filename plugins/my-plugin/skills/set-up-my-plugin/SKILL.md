---
name: set-up-my-plugin
description: Copy the minimalist-engineering principles into the user-level instruction files for Claude Code and Copilot CLI.
disable-model-invocation: true
license: MIT
compatibility: Claude Code, GitHub Copilot CLI
---

# Set up my-plugin

Run this skill by hand from the dotfiles checkout. It copies the principles from the minimalist-engineering skill into one user-level instruction file for each agent.

## Target files

| Agent | File | Why this file |
| --- | --- | --- |
| Claude Code | `~/AGENTS.md` | Claude Code loads AGENTS.md from the working directory and every directory above it, so this file applies to projects under your home folder. |
| Copilot CLI | `~/.copilot/copilot-instructions.md` | This is the user-level instructions file that Copilot CLI documents. |

Do not write `~/.claude/CLAUDE.md`, because this setup uses AGENTS.md for Claude Code. Do not write `~/.claude/AGENTS.md` or `~/.copilot/AGENTS.md`, because neither tool loads them.

## Steps

1. Run `git rev-parse --show-toplevel` from the dotfiles checkout and call the output `<root>`. Stop and ask for the checkout path if the command fails.
2. Set `<source>` to `<root>/plugins/my-plugin/skills/minimalist-engineering/SKILL.md`. Stop and report if that file does not exist.
3. Build the block. Copy the text of `<source>` below its closing `---` frontmatter line exactly. Wrap that text in these markers: `<!-- my-plugin:engineering start -->` before it and `<!-- my-plugin:engineering end -->` after it.
4. For each target file, do the following:
   1. Create the parent directory if it does not exist.
   2. If the target is a symlink, stop and report it. Do not write through a symlink.
   3. If the target does not exist, create it with the block.
   4. If the target contains both markers, replace the text from the start marker to the end marker with the block.
   5. If the target exists without markers, append the block to the end of the file.
5. Print each target path and confirm that each marker appears once.

The block is a copy, not a link. Rerun this skill after you edit minimalist-engineering.

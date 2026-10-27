# Shared skills

This repository holds shared skills for GitHub Copilot CLI and Claude Code.

The skills live in one plugin, `plugins/my-plugin`. It has two kinds of skills:

- Your own skills, as real folders in `plugins/my-plugin/skills/`.
- Upstream skills, as symlinks into pinned copies of upstream commits. The engineering skills from [mattpocock/skills](https://github.com/mattpocock/skills) are in `plugins/my-plugin/upstream-mattpocock/`, and `show-me` from [humanlayer/skills](https://github.com/humanlayer/skills) is in `plugins/my-plugin/upstream-humanlayer/`. Each copy records its commit in a `PIN.md` file.

## Install the plugin

Claude Code:

```bash
claude plugin marketplace add olillevik/dotfiles
claude plugin install my-plugin@dotfiles
```

If you registered an earlier checkout of this repository as a marketplace, remove it first with `claude plugin marketplace remove dotfiles`.

Copilot CLI:

```bash
copilot plugin install olillevik/dotfiles:plugins/my-plugin
```

Start a new session afterwards.

## Set up a machine

Clone this repository, then run the `set-up-my-plugin` skill from that checkout once per machine. It copies the principles from the `minimalist-engineering` skill into `~/AGENTS.md` for Claude Code and `~/.copilot/copilot-instructions.md` for Copilot CLI.

## Set up hooks in a clone

Run the `set-up-hooks` skill once in each clone you commit from. It installs a `commit-msg` hook that removes Claude and Copilot co-author lines, and a `pre-commit` hook that runs the repo's tests when it has any. The hooks live in that clone only, and the skill never changes `core.hooksPath`.

## Update

After you push changes, update the installed plugins:

```bash
claude plugin marketplace update dotfiles
claude plugin update my-plugin@dotfiles
copilot plugin update my-plugin
```

Then restart Claude Code and start a new Copilot CLI session. Rerun `set-up-my-plugin` after you edit `minimalist-engineering`, because the global files hold a copy. To update the upstream skills, follow [docs/updating-upstream-skills.md](docs/updating-upstream-skills.md).

Personal agents or persona-specific instruction files should live outside this repository. For example, a standalone personal coach agent can live at `~/trening/AGENTS.md` instead of under `plugins/my-plugin/skills/`.

# Install Shared Skills On Mac

This repository contains shared skills for GitHub Copilot CLI and Claude Code.

`install.sh` creates symlinks so these tool-specific paths all point to this repository's `skills/` directory:

- `~/.copilot/skills`
- `~/.claude/skills`

It also installs a global `commit-msg` hook through `~/.git-templates/hooks` and configures `git config --global core.hooksPath` to point there.

After installation, both tools will read the same skill files through those symlinks, and Git will use the shared hook setup.

Personal agents or persona-specific instruction files should live outside this repository. For example, a standalone personal coach agent can live at `~/trening/AGENTS.md` instead of under `skills/`.

Run these commands from the repository root.

Make the installer executable:

```bash
chmod +x install.sh
```

Run the installer:

```bash
./install.sh
```

Expected output:

```text
Linked: /Users/your-user/.copilot/skills -> /path/to/your/dotfiles/skills
Linked: /Users/your-user/.claude/skills -> /path/to/your/dotfiles/skills
Configured git core.hooksPath: /Users/your-user/.git-templates/hooks
Linked: /Users/your-user/.git-templates/hooks/commit-msg -> /path/to/your/dotfiles/hooks/git/commit-msg
```

The shared `hooks/git/commit-msg` hook removes `Co-authored-by` and `Generated-by` lines from commit messages so local history stays clean even when AI tools try to add trailers.

To update a shared skill or the commit hook, edit it in this repository, then rerun `./install.sh` if needed and start a new session for your agent tools.

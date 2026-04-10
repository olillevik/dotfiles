# Install Shared Skills On Mac

This repository contains shared skills for GitHub Copilot CLI and Claude Code.

`install.sh` creates symlinks so these tool-specific paths all point to this repository's `skills/` directory:

- `~/.copilot/skills`
- `~/.claude/skills`

After installation, both tools will read the same skill files through those symlinks.

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
```

To update a shared skill, edit it under this repository's `skills/` directory, then restart the tool or start a new session.

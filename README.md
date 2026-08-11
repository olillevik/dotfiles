# Install Shared Skills On Mac

This repository contains shared skills for GitHub Copilot CLI and Claude Code.

`install.sh` links each skill directory separately into these two paths, one symlink per skill:

- `~/.copilot/skills`
- `~/.claude/skills`

It links the skills in this repository's `skills/` directory and the skills from `mattpocock/skills`, which it clones to `~/.mattpocock-skills`.

The installer keeps no backups. Anything it finds in the way is replaced, on the assumption that the content it manages lives in git. It also removes symlinks that no longer resolve, which is what upstream renames and deletions leave behind.

It also links `AGENTS.md`, the shared writing-style instructions, into the three places agents look for global instructions:

- `~/.claude/AGENTS.md`
- `~/.claude/CLAUDE.md`
- `~/.copilot/AGENTS.md`

All three are symlinks to the same file. An existing file at any of those paths is replaced. `AGENTS.md` starts with `@~/.claude/RTK.md`, so the RTK instructions still load.

It also links `minimalist-engineering.md` to `~/.claude/minimalist-engineering.md`. `AGENTS.md` points agents at that path and tells them to read it when writing or reviewing code, so the principles load on demand rather than into every session.

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
Linking local skills into /Users/your-user/.copilot/skills
  linked git-commit
  linked terse
Linking mattpocock skills into /Users/your-user/.copilot/skills
  linked writing-tests
Linked: /Users/your-user/.claude/AGENTS.md -> /path/to/your/dotfiles/AGENTS.md
Linked: /Users/your-user/.claude/CLAUDE.md -> /path/to/your/dotfiles/AGENTS.md
Linked: /Users/your-user/.copilot/AGENTS.md -> /path/to/your/dotfiles/AGENTS.md
Configured git core.hooksPath: /Users/your-user/.git-templates/hooks
Linked: /Users/your-user/.git-templates/hooks/commit-msg -> /path/to/your/dotfiles/hooks/git/commit-msg
```

The shared `hooks/git/commit-msg` hook removes `Co-authored-by` and `Generated-by` lines from commit messages so local history stays clean even when AI tools try to add trailers.

To update a shared skill or the commit hook, edit it in this repository, then rerun `./install.sh` if needed and start a new session for your agent tools.

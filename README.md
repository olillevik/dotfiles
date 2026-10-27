# Install Shared Skills On Mac

This repository holds shared skills for GitHub Copilot CLI and Claude Code, the shared agent instructions, and a git commit hook.

The skills live in one Claude Code plugin, `plugins/dotfiles`. It has two kinds of skills:

- Your own skills, as real folders in `plugins/dotfiles/skills/`.
- Upstream skills, as symlinks into pinned copies of upstream commits. The engineering skills from [mattpocock/skills](https://github.com/mattpocock/skills) are in `plugins/dotfiles/upstream-mattpocock/`, and `show-me` from [humanlayer/skills](https://github.com/humanlayer/skills) is in `plugins/dotfiles/upstream-humanlayer/`. Each copy records its commit in a `PIN.md` file.

`install.sh` registers this checkout as a Claude Code marketplace and installs the `dotfiles` plugin. It links the same skills into `~/.copilot/skills`. It also links `AGENTS.md`, the shared writing-style instructions, into the three places agents look for global instructions:

- `~/.claude/AGENTS.md`
- `~/.claude/CLAUDE.md`
- `~/.copilot/AGENTS.md`

All three are symlinks to the same file. An existing file at any of those paths is replaced. `AGENTS.md` starts with `@~/.claude/RTK.md`, so the RTK instructions still load.

It also installs a global `commit-msg` hook through `~/.git-templates/hooks` and configures `git config --global core.hooksPath` to point there. The shared `hooks/git/commit-msg` hook removes `Co-authored-by` and `Generated-by` lines from commit messages so local history stays clean even when AI tools try to add trailers.

The installer removes the skill links that earlier versions created in `~/.claude/skills` and `~/.copilot/skills`, including links into the old `~/.mattpocock-skills` clone. Links to other sources, such as `~/.agents`, stay.

Run these commands from the repository root:

```bash
chmod +x install.sh
./install.sh
```

Expected output, shortened:

```text
Removing link: /Users/your-user/.claude/skills/tdd
Registering /path/to/your/dotfiles with Claude Code
Adding marketplace…✔ Successfully added marketplace: dotfiles (declared in user settings)
Installing plugin "dotfiles@dotfiles"...✔ Successfully installed plugin: dotfiles@dotfiles (scope: user)
Linking plugin skills into /Users/your-user/.copilot/skills
  linked ask-matt
  ...
  linked writing-for-agents
Linked: /Users/your-user/.claude/AGENTS.md -> /path/to/your/dotfiles/AGENTS.md
Linked: /Users/your-user/.claude/CLAUDE.md -> /path/to/your/dotfiles/AGENTS.md
Linked: /Users/your-user/.copilot/AGENTS.md -> /path/to/your/dotfiles/AGENTS.md
Configured git core.hooksPath: /Users/your-user/.git-templates/hooks
Linked: /Users/your-user/.git-templates/hooks/commit-msg -> /path/to/your/dotfiles/hooks/git/commit-msg

Install complete. Restart your agent tools or start a new session to pick up the skills.
```

To update your own skills or the commit hook, edit it in this repository. Start a new session, or run `/reload-plugins` in Claude Code. Rerun `./install.sh` if you changed the instructions, the hook, or the Copilot links. The plugin loads from this checkout, so a `git pull` takes effect the same way.

Personal agents or persona-specific instruction files should live outside this repository. For example, a standalone personal coach agent can live at `~/trening/AGENTS.md` instead of under `plugins/dotfiles/skills/`.

To update the upstream skills, follow [docs/updating-upstream-skills.md](docs/updating-upstream-skills.md).

# Updating the upstream skills

Some skills in this plugin are copies of skills from other repositories. Each upstream has its own folder under `plugins/my-plugin/`:

- `upstream-mattpocock/` holds [mattpocock/skills](https://github.com/mattpocock/skills): the 20 engineering skills, plus `grilling` and `writing-for-agents`.
- `upstream-humanlayer/` holds [humanlayer/skills](https://github.com/humanlayer/skills): the `show-me` skill.

Each folder contains `PIN.md`, which records the upstream repository and the commit the copy came from. It also contains a `LICENSE` copied from upstream, and the skill folders at the same paths they have upstream. The skills in `plugins/my-plugin/skills/` that come from upstream are symlinks into these folders. An update copies exactly the skills that have a symlink.

## Run an update

Start from a clean `main`, then run one of these:

```bash
scripts/update-upstream.sh upstream-mattpocock               # newest commit on upstream main
scripts/update-upstream.sh upstream-mattpocock <sha>         # a specific commit
scripts/update-upstream.sh upstream-humanlayer --dry-run     # copy and report, then stop
```

Without `--dry-run`, the script creates a branch named `update-<folder>-<short sha>`, commits the new copy, pushes the branch, and opens a PR against `main`. With `--dry-run`, it changes files in the working tree and stops before any git write. Until you commit or discard those changes, later runs refuse to start.

If a linked skill is missing upstream at the new commit, the script stops and leaves the repository unchanged.

## Review the PR

1. Open the Files tab. It shows every changed file in the copy folder.
2. Read the description. It lists the upstream commits that touch the copied skills, and it links the compare view.
3. Check the list of new upstream skills in the same folders. The script does not copy them. Add one only on purpose (see below).
4. Look for these:
   - New or removed skill folders.
   - Changes to `name`, `description`, or `disable-model-invocation` in any `SKILL.md`. These change when an agent loads the skill.
   - Changes to scripts and templates inside the skill folders. Read every line.
   - New instructions that tell an agent to run commands, reach the network, or write outside the project.

## After the merge

Pull `main` in each checkout, then start a new agent session or run `/reload-plugins`. The plugin reads the checkout.

## Add or remove a skill

To take a skill that the upstream copy already has, copy its folder from the pinned commit to the same path under the copy folder, then add a symlink for it in `plugins/my-plugin/skills/`. To drop a skill, delete its symlink and its copy. The next update also drops any copy that has no symlink.

## Add another upstream

1. Create a folder `plugins/my-plugin/upstream-<name>/`.
2. Add `PIN.md` with `Upstream`, `Commit`, and `Committed` lines. Copy an existing `PIN.md` and change the values.
3. Copy the upstream `LICENSE` into the folder.
4. Copy each skill folder to the same path it has upstream, and add a symlink in `plugins/my-plugin/skills/` with the target `../upstream-<name>/<path>`.
5. Run `scripts/update-upstream.sh upstream-<name> --dry-run` to check the copy, then run `./install.sh` so Copilot picks up the new skills.

## Do not edit a copy by hand

The next update replaces everything in a copy folder except `PIN.md` and `LICENSE`. Put personal changes in a personal skill under `plugins/my-plugin/skills/`.

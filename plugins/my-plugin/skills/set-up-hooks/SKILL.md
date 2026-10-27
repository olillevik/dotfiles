---
name: set-up-hooks
description: Set up recommended git hooks in the current repository. Strips Claude and Copilot co-author lines from commit messages, and runs the repo's tests before each commit when it has any. Use only when the user explicitly asks to set up hooks.
disable-model-invocation: true
license: MIT
compatibility: Claude Code, GitHub Copilot CLI
---

# Set up hooks

Run this skill by hand from the repository, once per clone. It writes hooks into the hooks directory that git uses in this clone. It never changes `core.hooksPath`, so other repositories and other machines are unaffected.

## Steps

1. **Find the hooks directory.** Run `git rev-parse --git-path hooks`. Stop and report if the command fails.
   - Done when you have the path.

2. **Check for existing hooks.** Look at `commit-msg` and `pre-commit` in that directory. A file whose second line is `# set-up-hooks` is ours and may be replaced. Any other existing file: stop and ask the user before replacing it.
   - Done when neither file belongs to someone else.

3. **Choose the test command for `pre-commit`.** Use the first match below, and ask the user if more than one applies:
   - `package.json` with a `test` script: `npm test`, or `pnpm test` or `yarn test` when `pnpm-lock.yaml` or `yarn.lock` exists.
   - `go.mod`: `go test ./...`
   - `Cargo.toml`: `cargo test`
   - `*.sln` or `*.csproj`: `dotnet test`
   - `pyproject.toml`, `pytest.ini`, or a `tests/` directory: `pytest`
   - a `test` target in `Makefile`: `make test`

   If nothing matches, ask the user for the command, or skip `pre-commit` if the repo has no tests.
   - Done when you have a command, or the user has chosen to skip it.

4. **Write the hooks.** Create the hooks directory if it is missing. Write `commit-msg` from the template below. Write `pre-commit` only when you have a test command. Make each file you write executable.
   - Done when the files exist and are executable.

5. **Verify and report.** Run `sh -n` on each file you wrote. Report the hook paths, the test command, and that `core.hooksPath` is unchanged. Tell the user the hooks apply to this clone only, so the skill must be run in each clone. Do not use `git commit --no-verify` to get past a hook unless the user asks.

## Templates

`commit-msg`:

```sh
#!/bin/sh
# set-up-hooks
set -eu

msg=$1
tmp="$msg.tmp"

grep -viE '^Co-authored-by:.*(claude|copilot|@anthropic\.com)' "$msg" > "$tmp" &&
mv "$tmp" "$msg"
```

`pre-commit`, only with a test command:

```sh
#!/bin/sh
# set-up-hooks
set -eu

<test command>
```

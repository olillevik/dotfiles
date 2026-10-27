---
name: set-up-workflow
description: Set up how this repo's issues and tickets are handled. Runs setup-matt-pocock-skills, then records the spec and ticket workflow under "Issue tracker" in AGENTS.md. Use only when the user explicitly asks to set up the workflow.
disable-model-invocation: true
license: MIT
compatibility: Claude Code, GitHub Copilot CLI
---

# Set up workflow

Run this skill by hand from the repository you want to configure. It works in any repository and with any issue tracker. This skill names no tracker: setup-matt-pocock-skills decides which one the repo uses, and `docs/agents/issue-tracker.md` holds its operations.

## Steps

1. **Run setup-matt-pocock-skills.** Read `../setup-matt-pocock-skills/SKILL.md` and carry out its process from start to finish: explore, ask, confirm, write. Its questions go to the user.
   - Override its file choice: the `## Agent skills` block goes to `AGENTS.md`, created if missing. Never write `CLAUDE.md`.
   - If `CLAUDE.md` already has an `## Agent skills` block, raise it at the confirm step and do not move it.
   - Done when setup-matt's files are written, or the user has declined them.

2. **Write the workflow into AGENTS.md.** Set `<root>` to the output of `git rev-parse --show-toplevel`. Stop and report if that command fails, or if `<root>/AGENTS.md` is a symlink.
   - Under `## Agent skills` → `### Issue tracker`, place the workflow block from the section below between its markers. If the markers already exist, replace everything from the start marker through the end marker. Otherwise insert the block after the `### Issue tracker` summary line. If either heading is missing, create it.
   - Done when each marker appears once and `### Issue tracker` appears once under `## Agent skills`.

3. **Report.** Print the path of `AGENTS.md` and every file that steps 1 and 2 wrote. Say what was skipped.

## Workflow block

Insert this block verbatim, without indentation:

```markdown
<!-- my-plugin:issue-workflow start -->
- **Spec from an existing ticket**: add the spec to that ticket's body under a `## Spec` heading, replacing any existing `## Spec` section. Apply the label for the `ready-for-agent` role (see `docs/agents/triage-labels.md`).
- **Spec with no existing ticket**: create a new ticket for the spec.
- **Implementation tickets** (for example from `to-tickets`): create each one as a sub-issue of the ticket it was based on, the existing ticket or the spec ticket. With no such ticket, create standalone tickets.
- **Sub-issue operation**: see `docs/agents/issue-tracker.md`. If the tracker has none, link parent and child both ways: the child refers to its parent, and the parent's body gets a `## Child tickets` checklist with one line per child. This overrides to-tickets' rule against modifying the parent, for these links only. Do not change the parent's open or closed state.
<!-- my-plugin:issue-workflow end -->
```

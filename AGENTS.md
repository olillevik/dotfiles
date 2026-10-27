## Agent skills

### Issue tracker

Issues and specs live as GitHub Issues in olillevik/dotfiles, managed with the gh CLI. See `docs/agents/issue-tracker.md`.

<!-- my-plugin:issue-workflow start -->
- **Spec from an existing ticket**: add the spec to that ticket's body under a `## Spec` heading, replacing any existing `## Spec` section. Apply the label for the `ready-for-agent` role (see `docs/agents/triage-labels.md`).
- **Spec with no existing ticket**: create a new ticket for the spec.
- **Implementation tickets** (for example from `to-tickets`): create each one as a sub-issue of the ticket it was based on, the existing ticket or the spec ticket. With no such ticket, create standalone tickets.
- **Sub-issue operation**: see `docs/agents/issue-tracker.md`. If the tracker has none, link parent and child both ways: the child refers to its parent, and the parent's body gets a `## Child tickets` checklist with one line per child. This overrides to-tickets' rule against modifying the parent, for these links only. Do not change the parent's open or closed state.
<!-- my-plugin:issue-workflow end -->

### Triage labels

Triage roles use the default label names: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.

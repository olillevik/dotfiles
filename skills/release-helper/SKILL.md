---
name: release-helper
description: Draft release notes, changelog entries, and pull request summaries from diffs, commit ranges, or PR context. Use when the user wants release-writing from code changes; if the same request also includes a commit message request, reuse `git-commit` for that portion.
license: MIT
compatibility: Claude Code, GitHub Copilot CLI
---

# Release Helper

## What I do
- Draft release notes, changelog entries, and PR summaries from code changes
- Focus on user impact, risks, and rollout-relevant detail instead of implementation trivia
- Adapt the output to the requested audience and format without forcing one template
- Reuse `git-commit` for standalone or mixed commit-message work

## When to use me
Use this skill when the user wants release notes, a changelog entry, or a pull request summary based on a diff, commit range, staged changes, or PR context. Do not use it for a plain commit message request; that belongs to `git-commit`. If the request mixes release-writing and commit-message work, keep the release-writing here and hand the commit-message portion to `git-commit`.

## Inputs or prerequisites
- A source of truth such as a staged diff, branch diff, commit range, compare view, or pull request context
- Enough context to tell what changed and why it matters
- Any audience or format preference the user gives, such as "customer-facing", "internal", "bullet list", or "PR body"

## Workflow
1. Identify the artifact and audience.
   - Decide whether the user needs release notes, a changelog entry, a PR summary, or more than one artifact.
   - Match the tone and structure to the target audience instead of forcing a rigid format.

2. Gather the evidence that best explains the change.
   - Prefer diffs, commit ranges, PR descriptions, issue links, and related context over filenames alone.
   - If a comparison target or PR reference is missing, ask for it instead of guessing.

3. Extract the meaningful changes.
   - Group related work into features, fixes, operational changes, and internal-only updates when that split helps.
   - Call out breaking changes, migrations, config updates, risks, and follow-up items when the evidence supports them.
   - Skip low-value implementation detail unless the user asks for a deeper technical summary.

4. Draft the requested artifact.
   - Lead with the most important impact.
   - Keep the output concise, scannable, and ready to paste into a PR, changelog, or release note.
   - If something is uncertain, say so plainly instead of overstating the change.

5. Keep neighboring workflows separate.
   - If the request also includes a commit message request, reuse `git-commit` for that part.
   - Do not replace `git-commit` for commit-subject drafting.
   - Do not turn this skill into a general code-review workflow.

## Output expectations
- Faithful to the actual diff or commit range
- Focused on impact, not filenames or raw implementation detail
- Clear about breaking changes, risks, and upgrade steps when relevant
- Separate artifacts when both release text and commit text are requested
- Concise enough to use directly with minimal editing

## Examples
- "Write release notes for v2.3.0..HEAD and highlight anything customers need to know."
- "Summarize this PR in a short PR body with rollout notes."
- "Draft release notes for the staged changes, then reuse `git-commit` to handle the commit message."
- "Turn this compare diff into a changelog entry for internal release notes."

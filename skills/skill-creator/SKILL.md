---
name: skill-creator
description: Create, review, and improve skills in this repository for GitHub Copilot CLI and Claude Code. Use when drafting a new skill, revising an existing skill under skills/, tightening trigger boundaries, or making a skill leaner and more portable.
license: MIT
compatibility: Claude Code, GitHub Copilot CLI
---

# Skill Creator

Create clear, portable skills for this repository's `skills/` directory.

## What I do

- Turn a rough workflow or idea into a well-structured skill
- Rewrite existing skills to be clearer, leaner, and easier to trigger correctly
- Keep skills portable across GitHub Copilot CLI and Claude Code
- Tighten boundaries between neighboring skills so they do not steal each other's prompts
- Remove unnecessary host-specific assumptions and verbose instructions

## When to use me

Use this skill when you need to create a new skill, revise an existing skill, improve a skill description, or make a skill in this repo more uniform, concise, and reliable.

## Repository defaults

In this repository, "create a skill" means:

- create or edit it under `skills/<skill-name>/`
- make it work in both GitHub Copilot CLI and Claude Code unless the user explicitly asks for a host-specific fork
- use the shared cross-tool frontmatter and structure by default

Do not require the user to say "shared skill" to get the default behavior for this repo.

## Core principles

1. **Cross-tool by default**
   - Default to one skill that works in both GitHub Copilot CLI and Claude Code.
   - Only split into host-specific variants when the user explicitly wants that or the workflow truly cannot be shared cleanly.

2. **Lean instructions**
   - Prefer clear, direct instructions over long frameworks, rigid ceremony, or defensive boilerplate.
   - Keep the skill focused on the task it owns.

3. **Strong trigger boundaries**
   - The description should say what the skill does and when it should be used.
   - If another skill owns a neighboring task, do not let this skill's description claim those prompts.

4. **Portable wording**
   - Avoid hidden internals, host-specific CLIs, browser-only steps, or product-specific assumptions unless the skill is intentionally tied to one host.

5. **Practical reuse**
   - Reuse nearby skills and existing repo conventions instead of inventing parallel workflows.

## Recommended skill anatomy

Use this structure unless the user has a strong reason to do otherwise:

```markdown
---
name: <skill-name>
description: <what it does and when to use it>
license: MIT
compatibility: Claude Code, GitHub Copilot CLI
---

# <Title>

## What I do
- ...

## When to use me
Use this skill when ...

## Inputs or prerequisites
- ...

## Workflow
1. ...
2. ...
3. ...

## Output expectations
- ...

## Examples
- ...
```

Add `references/`, `scripts/`, or `assets/` only when they clearly improve reuse.

## Workflow

### 1. Understand the task

Start by understanding:

1. What should this skill help the agent do?
2. What kinds of user requests should trigger it?
3. What output should it produce?
4. Does it fit the default cross-tool style for this repo, or is the user explicitly asking for a host-specific variant?

Extract as much as you can from the current conversation before asking follow-up questions.

### 2. Check the repository first

Before writing anything:

- inspect `skills/` for nearby patterns, naming conflicts, or existing skills that already solve part of the problem
- reuse conventions already present in this repository
- if the user wants to modify an existing skill, read it carefully and preserve good parts instead of rewriting blindly

### 3. Ask only the questions that matter

Ask about:

- scope boundaries
- required inputs and outputs
- edge cases that change behavior
- overlap with neighboring skills

If there are multiple reasonable designs, ask the user to choose. Do not ask them to design the whole skill for you.

### 4. Decide whether it should stay cross-tool

Default to the shared cross-tool format used by this repo. Only recommend a split if:

- one host requires fundamentally different instructions
- one host depends on tools or behaviors the other cannot access
- combining both would make the skill confusing or unreliable

If a split is needed, explain why and keep the default version clean instead of stuffing host-specific branches into it.

### 5. Draft or revise the skill

Write a draft that is:

- clear
- action-oriented
- specific about when to use the skill
- free of host-specific assumptions
- easy to scan

Good descriptions are concrete. Weak: "Helps with spreadsheets." Better: "Analyze, clean, transform, and summarize spreadsheet data. Use when the user mentions Excel files, workbooks, tabs, formulas, CSV cleanup, reporting tables, or asks to inspect or modify structured tabular files."

### 6. Check boundaries with neighboring skills

Before finalizing the description, do a boundary check:

- if this skill delegates a task to another skill, do not describe that delegated task as a primary reason to trigger this skill
- mention delegation in the body if useful, but keep the description focused on the task this skill actually owns
- if nearby skills overlap, make the handoff explicit and concise

Example:

- Good: "Draft release notes and PR summaries from diffs and commit ranges. If the same request also includes a commit message request, reuse `git-commit` for that part."
- Bad: "Draft release notes and turn staged changes into a commit message" when plain commit message requests should belong to `git-commit`

### 7. Add supporting resources only when justified

If repeated work would clearly benefit from bundled material:

- add `references/` for large factual guidance
- add `scripts/` for deterministic repeatable work
- add `assets/` for templates or files used in outputs

Do not add extra structure just because the format allows it.

### 8. Finalize the skill

Before considering the work done:

- make sure the description clearly signals when to use the skill
- confirm the body is understandable without host-specific knowledge
- confirm the result still fits the default cross-tool Copilot + Claude setup for this repo
- tell the user where the skill lives in `skills/<name>/`
- remind them that changes take effect in a new session or after restart

## Validation rules

### Name

- lowercase letters, digits, and single hyphens only
- no leading or trailing hyphen
- no consecutive hyphens
- should match the directory name

Regex:

```regex
^[a-z0-9]+(-[a-z0-9]+)*$
```

### Description

The description should:

- say what the skill does
- say when to use it
- include realistic trigger language
- avoid host-specific jargon unless the skill is intentionally host-specific
- avoid claiming prompts that should primarily trigger a neighboring skill
- mention delegated work only in a way that preserves the other skill's trigger boundary

### Portability

A shared repo skill is not ready if it:

- depends on Claude-only commands or environments
- depends on Copilot-only commands or environments
- assumes hidden implementation details of one host
- mixes multiple incompatible workflows into one confusing set of instructions

## Review checklist

1. **Purpose**
   - Is the skill's job obvious within the first few lines?

2. **Triggering**
   - Does the description explain both what it does and when it should be used?
   - Would a real user prompt match the wording?
   - If another skill owns part of the workflow, does the description avoid stealing that other skill's primary prompts?

3. **Portability**
   - Could the core instructions work in both GitHub Copilot CLI and Claude Code?
   - Are host-specific assumptions removed or minimized?

4. **Usability**
   - Is the workflow easy to follow?
   - Are outputs and constraints clear?

5. **Leanness**
   - Is anything here redundant, overly defensive, or more complicated than it needs to be?

## Good and bad patterns

### Good

- "Use this skill when the user wants release notes, a changelog entry, or a PR summary from a diff or commit range."
- "Draft release notes and PR summaries. If the request also includes a commit message request, reuse `git-commit` for that portion."
- "Reuse the existing repo convention unless there is a real reason to change it."

### Bad

- "Run a host-specific CLI flow to test triggering."
- "This only works in tool X, but keep it as the shared version anyway."
- "Use this skill for release notes or commit message requests" when commit message requests are supposed to belong to `git-commit`.
- "Always follow this exact rigid format" without explaining why the format matters.

## Default recommendation for this repository

If the user is working in this repo and has not said otherwise:

- create or edit the skill under `skills/<skill-name>/`
- make it work for both GitHub Copilot CLI and Claude Code
- avoid host-specific sections
- prefer one clean shared skill over multiple near-duplicates
- keep the skill concise and practical

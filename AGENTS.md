@~/.claude/RTK.md

# Engineering

When writing or reviewing code, read and follow the minimalist engineering
principles in `~/.claude/minimalist-engineering.md`.

# Writing style

Rules for prose you write for me. Not for code, and not for text you are quoting.

## Rule zero: meaning is invariant

This rule beats every other rule in this file. When a style rule and this one
disagree, this one wins and you say so in your report.

A style pass must not change behaviour. Never touch a word carrying a count,
threshold, modal, scope, or condition. "Multiple" is not "several": one means more
than one, the other more than two. Same for must / should, all / most, never /
rarely, `clearly required` / `required`.

Deleting a word is an edit. Before dropping any adjective, adverb, or conditional,
name the thing it constrains. If you can name one, keep the word. This is the test
behind most of what follows: where a later rule says "name the wrong behaviour it
rules out", this is what it means.

Never invent a value, threshold, or test you have no basis for. If a rule demands
a specific test and you don't have one, keep the vague original and flag it.

## Two registers

Prose is anything a person reads as sentences: READMEs, docs, PR descriptions,
commit bodies, issue text, chat replies, comments. Default to paragraphs.

Spec is a normative document an agent executes: `SKILL.md`, `AGENTS.md`, a
checklist someone follows. Structure is load-bearing here. Keep headings, numbered
steps, and tables. Keep `do not` / `must` / `never`. An unmissable prohibition
beats a friendly one.

Spec gets looser thresholds, and one exemption, named where it applies. Nowhere
else is a register a place to hide.

## Budgets

Count these. Never estimate. A number you did not compute is a rule you did not
apply, and the counts include YAML frontmatter.

| | Prose | Spec | |
|---|---|---|---|
| Inline-header list items | 0 | 2 per list, 6 per file | enforced |
| Bullet lines | 40% of file | 65% of file | enforced |
| Trailing -ing commentary | 0 | 0 | enforced |
| Rhetorical triads | 1 per 50 lines | 1 per 50 lines | census |
| Contrast clauses | 1 per `##` section | 1 per `##` section | census |

Enforced means fix it or report it over budget. Census means count it, report the
number, and change nothing unless the fix costs nothing. The two census rows earn
that status: in a spec file nearly every triad turns out to be three separate
requirements, and nearly every negative half names a wrong behaviour the positive
half alone would not stop. Counting still catches the outlier. Acting damages the
file.

A budget is a ceiling, not a target. If a row is already under budget, change
nothing for that row and report the number. A file under every budget gets no
structural edit at all: no de-bulleting, no merging, no promoting labels to
headings. Fix outright errors and leave the rest. Most of the damage a style pass
does comes from editing files that were already fine.

No fix for one row may push another row up. If flattening a list would create a
trailing participle, a bullet over about 30 words, or an item that breaks the
list's parallelism, leave the list alone and report it over budget. Report beats
damage.

### What counts

An **inline-header list item** is shaped `marker + short capitalised phrase + colon
or full stop + description`. Removing the bold does not fix one; the shape is the
tell.

**Trailing -ing commentary** is a participial clause hung off a comma at the end of
a sentence to editorialise: "…, ensuring consistency across the codebase." Cut the
clause. If it carried a fact, make it its own sentence.

A **rhetorical triad** is three items where dropping one costs nothing. Count
requirements, not words: "concise, scannable, and ready to paste" is three
constraints and stays, and a font fallback stack is a fact and stays.

A **contrast clause** is any sentence whose second half exists to reject the first
half's alternative: "not X but Y", "X rather than Y", "X, not Y", "prefer X over
Y", "X is better than Y". Matching connectives is not the test. Removing the
negative half and seeing whether a named alternative disappears is. A section is
the text under one `##` heading.

### Fixing inline-header list items

Three honest fixes: fold the label into the first sentence; promote the label to a
real `###` heading; or, when the labels are lookup keys someone scans for, keep the
list as a table with the labels as its first column.

Promote only when the label heads three or more lines of content, and never out of
a numbered list whose count someone tracks. Headings do not self-count, and "3 of 5
checked" stops being sayable. After promoting, run
`grep '^#' <file> | sort | uniq -d`. A collision is a failed promotion: rename it
or fold the label back in. If a file gains more than three headings in one pass,
revert and fold instead.

Convert to a table only when the column header is true of every cell beneath it.
Read the first column top to bottom: if any cell is a sentence rather than a label,
the table is wrong and the list stays a list. A two-column table of label and
description is the same tell wearing pipes.

Exempt in spec only: a list of named things with a definition under each, the kind
a glossary or a rule list needs. The labels are the index, and you cannot look a
rule up without one. Count the exempt items and report the number anyway. Prose
keeps a budget of 0 and gets no exemption.

### Fixing bullet lines

Over budget means a list is doing a paragraph's work. Only then, merge a list whose
items are all single clauses of the same shape into one sentence. Never merge items
that are separately checkable constraints or values someone looks up, however
uniform their shape. Those are a table, or they stay a list.

## Words to cut

Evidence-backed, from studies of LLM output. The list is literal: a banned word
does not ban its synonyms, and swapping in a synonym is not the fix. Rewriting the
sentence is.

align with, additionally (as a sentence opener), boasts (meaning "has"), bolster,
crucial, delve, emphasize, enduring, enhance, foster, garner, highlight (as a verb),
intricate, interplay, key (as an adjective), landscape (figurative), meticulous,
pivotal, robust, showcase, tapestry, testament, underscore, valuable, vibrant.

Weaker evidence, still worth cutting on sight: leverage (as a verb), seamless,
streamline, holistic, comprehensive, cutting-edge, unlock (figurative).

When the banned word sits in a fragment with no sentence around it, a table cell, a
heading, or a list label under about six words, there is nothing to rewrite. Leave
it and flag it. A one-word substitution in a table cell is the likeliest way to
invent a distinction the document never made.

Exempt: quoted text, and example prompts a document uses for trigger matching.
Flag those rather than editing them.

## Sentence shapes to avoid

- **Significance inflation.** "stands as", "serves as a testament to", "plays a key
  role in", "marks a turning point", "reflects broader trends". Never tell the
  reader something matters. State what it does.
- **Copula avoidance.** Write "is", "are", "has". Not "serves as", "functions as",
  "represents", "features", "offers", "refers to".
- **Vague attribution.** "Experts argue", "studies show", "widely used",
  "industry-standard". Name the source or drop the claim.
- **Hedge-imperatives.** "Consider doing X", "aim to X" in a document whose job is
  to state a rule. Either it is the rule or it is not. But converting "prefer X
  over Y" into "do X" changes a ranking into an absolute, which rule zero forbids.
  Keep the ranking and drop the hedge: "Default to X."
- **Escape-hatch conditionals.** "when that helps", "where appropriate", "unless
  there is a real reason". Give the test in the same sentence or keep the original.
  A cross-reference is not a fix: "see step 7 below" makes the reader jump to find
  the same vagueness, and it breaks when the steps are renumbered.
- **Symmetric restatement.** Stating a rule and then its inverse. Say it once,
  unless the boundary is genuinely surprising.
- **Title restatement.** The first line after a heading paraphrasing the heading.
  Start with the first real fact.
- **Challenges-and-outlook endings.** "Despite these challenges..." plus an upbeat
  closing paragraph. Stop when the facts run out.
- **Unfilled placeholders.** `[Your Name]`, `INSERT_URL`, `2025-XX-XX`. Never ship
  one. If you don't know a value, say so.

## Word choice

Five documented pairs; use the left one: wrote / authored, used / utilized, tried /
attempted, moved / relocated, died / passed away.

Beyond those five, do not swap words for shorter synonyms. Formal or wordy prose is
not itself a tell, and a synonym hunt is how you introduce bugs.

Repeat a word rather than varying it. If the thing is a symlink, call it a symlink
every time. Alternating between "symlink", "the link", and "this pointer" is a
strong AI tell and it makes text harder to follow.

## Formatting

- Sentence case in headings. Proper nouns stay capitalised.
- Keep list items and table columns grammatically parallel. Write down the shape of
  item 1 (imperative verb, noun phrase, comma-joined pair) and fix any item that
  does not match. Fix the outlier, not the list. Never split one bullet into two
  sentences if that gives it two verb registers; that is how a count-driven edit
  breaks a list.
- Bold anchors a list label or a table header. Never bold a term inside running
  prose. Before you remove one, look for siblings: two or more bold labels heading
  parallel blocks in the same `##` section are labels, and the whole set stays or
  the whole set goes. Removing one of three is the worst available outcome.
- One prohibition verb per file: `Avoid`, `Never`, or `Do not`. Unify all of them
  or none, because a half-converted file reads as though the converted rules are
  stronger. When converting `Avoid X, Y, and Z`, supply the missing verb and switch
  `and` to `or`: `Do not include X, Y, or Z`. Under negation, `and` forbids only
  the combination.
- Straight quotes and apostrophes in Markdown source and code.
- Em dashes unspaced, and rarely. There is no quota. Spaced em dashes are the tell.
- No emoji decorating headings or bullets. No horizontal rule before a heading.
- Never skip heading levels. A file that opens at `##` is missing its `#`.
- Files of one type (every `SKILL.md`, every ADR, every runbook) should share a
  skeleton. Before you restructure a construct in one file, grep the other files of
  that type for it. Fix it everywhere or nowhere, and report which you chose.
- No comma before a coordinating conjunction joining two conditions in one clause:
  "If two summaries are plausible or the user wants a body, ask." No comma before
  purposive "so".

## What good writing looks like

Models avoid these. Humans do them.

- Plain statements of fact. "There is a hook in `hooks/git/`. It strips two kinds
  of trailer."
- Definite claims when they are true. "This is the only place the path is set."
- Hedges and intensifiers. "Very", "perhaps", "tends to", "clearly", "genuinely"
  are documented markers of *human* writing. Keep them. The only intensifier worth
  cutting is one propping up a claim of importance: "a truly pivotal release".
- Wordy human constructions. "In order to", "the fact that", "as a result of".
- Contractions where the register is conversational. Not in spec text. Whichever
  you pick, apply it to the whole file including frontmatter.
- Concrete detail. The filename, the flag, the number. Specificity is the best
  defence against sounding generated, because models drift toward the generic.
- Uneven sentence length. Vary it. A short one lands after a long one.

## Editing someone else's text

Never shorten a sentence that is already clear. Never delete a framing or
scope-setting sentence to save a line. Bland, compressed prose is not evidence of
human authorship.

When you are done, `diff` each file and read only the changed lines. For each one,
name the behaviour difference or write "none". Anything you cannot mark "none" goes
back. Check specifically: did a threshold word disappear, did a list gain or lose
an item, does the file now assert two different things.

## Before you hand text over

Report every budget number, before and after. Over budget means not done.

1. Inline-header list items. Sum these two greps:
   `grep -cE '^\s*([-*]|[0-9]+\.)\s+\*\*' <file>`
   `grep -cE '^\s*([-*]|[0-9]+\.)\s+[A-Z][A-Za-z0-9 /_-]{0,30}[:.]\s+\S' <file>`
   The second is the one that matters after a pass. If the first drops to zero
   while the sum holds steady, you moved the tell instead of removing it.
2. `**` outside list items and table headers. Classify each hit before touching it.
   A bold label heading a block below it is a label; bold on a term inside a
   sentence goes. Show the list. "All hits are labels" is a valid finding.
3. `grep -ciE 'avoid|never|do not' <file>`. Case-insensitive: lowercase counts.
4. `grep -c ' — ' <file>`. Zero.
5. `grep '^# ' <file>`. Sentence case, proper nouns excepted. Check every sibling
   file of the same type: fixing one H1 and leaving four is worse than fixing none.
6. Every banned word, and every shape under "Sentence shapes to avoid". Zero hits,
   excluding what this document quotes as good.
7. Does anything in the file contradict anything else in it, or contradict a code
   block or sample output in the same file?

## Appendix: rarely fires, check anyway

Curly quotes, emoji as formatting, thematic breaks before headings, "In conclusion",
"It's important to note that", knowledge-cutoff disclaimers, canned notability
claims. Transition words on their own ("Moreover", "Furthermore", "Notably") are a
weak signal; cut them for concision, not because they prove anything.

---
name: sopra-steria-brand
description: Apply Sopra Steria brand styling to a presentation, document, web page, diagram, or other artifact when the user explicitly wants Sopra Steria branding or refers to Sopra Steria brand rules, colors, typography, logo usage, or corporate visual identity. Do not use for generic design polish or unrelated branding work.
license: MIT
compatibility: Claude Code, GitHub Copilot CLI
---

# Sopra Steria Brand

## What I do
- Apply Sopra Steria colors, typography, and visual identity to the artifact the user is working on
- Adapt the guidance to slides, documents, UI, diagrams, and similar deliverables
- Keep the result usable when proprietary fonts or logo files are unavailable

## When to use me
Use this skill when the user explicitly wants **Sopra Steria** branding or asks for Sopra Steria brand rules to be applied. Good triggers include requests about Sopra Steria brand colors, typography, logo usage, corporate identity, visual identity, or styling a specific asset to match Sopra Steria. Do not use it for generic requests like "make this prettier", "format this document", or branding for another company.

## Inputs or prerequisites
- An artifact to style, review, or describe
- A request that clearly points to Sopra Steria branding
- Any delivery constraints the user gives, such as PowerPoint, Word, HTML/CSS, diagram, or template work

## Core brand tokens

### Colors
| Token | Hex | Typical use |
| --- | --- | --- |
| Sopra Steria Purple | `#4d1d82` | Primary headings, key accents |
| Dark Purple | `#2a1449` | Deep accents, dark backgrounds |
| Background Purple | `#ede9f2` | Light section backgrounds |
| Background Beige | `#fdf2e5` | Alternate light backgrounds |
| Black | `#1d1d1b` | Body text |
| Warm Purple | `#8b1d82` | Secondary accent |
| Orange | `#f07d00` | Highlight and call-to-action accent |
| Red | `#cf022b` | Warning or critical emphasis |
| Grey | `#a8a8a7` | Neutral secondary elements |
| Light Grey | `#ededed` | Subtle backgrounds and dividers |

### Typography
- Headings: Hurme Geometric Sans 4 Bold
- Body: Hurme Geometric Sans 3 Regular
- Sensible fallback when brand fonts are unavailable: Tahoma, then Arial, then sans-serif

## Workflow
1. Confirm that the request is specifically about Sopra Steria branding.
   - If the request is only generic formatting or design polish, do not force this skill.
   - If the company or brand is ambiguous, ask instead of assuming Sopra Steria.

2. Identify the artifact and translate the brand to that medium.
   - Slides and documents: use purple-led headings, dark readable body text, restrained orange accents, and light purple or beige section backgrounds.
   - Web/UI: expose the brand colors and font stack as reusable theme tokens.
   - Diagrams: apply the palette sparingly and keep structure readable before decorative styling.

3. Handle missing brand assets honestly.
   - Do not invent or recreate official logos.
   - If brand fonts are unavailable, use the defined fallbacks and say so plainly.
   - If exact logo placement or asset files matter and are not provided, ask for them.

4. Deliver the smallest useful branded result.
   - Prefer direct edits, theme variables, style rules, or concise guidance the user can apply immediately.
   - Keep branding faithful without over-decorating the artifact.

## Output expectations
- The output clearly reflects Sopra Steria visual identity
- Color and typography choices are concrete enough to implement
- Assumptions about missing fonts or logos are explicit
- The skill stays focused on brand application, not generic writing or unrelated design work

## Examples
- "Restyle this slide deck to match Sopra Steria branding."
- "Apply Sopra Steria colors and typography to this HTML page."
- "Give me a Sopra Steria-branded theme for this document template."
- "Check whether this diagram follows Sopra Steria visual identity."

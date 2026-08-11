# Minimalist engineering principles

When writing or modifying code, do not over-engineer. Follow the **Lazy Senior Developer Ladder** in order:

## The priority ladder

Before writing any new code, stop at the first rung that satisfies the requirement:

1. **YAGNI (Does this need to exist?):** If a feature, abstraction, or piece of code is unnecessary to fulfill the prompt, omit it.
2. **Reuse Existing Code:** Inspect the existing codebase first. Reuse established utilities, patterns, and modules before writing new ones.
3. **Standard Library:** Leverage language built-ins and standard libraries before implementing custom algorithms or pulling in third-party libraries.
4. **Native Capabilities:** Prefer built-in language or system features over custom wrappers or abstractions.
5. **Existing Dependencies:** Utilize dependencies already declared in the project before adding new external packages or frameworks.
6. **Minimum Viable Code:** Write the smallest, most direct implementation that completely meets the task requirements.

## Safety and non-negotiables

Never compromise software quality for brevity. The following must **never** be omitted or golfed:
- Input validation, security boundaries, and sanitizer logic.
- Robust error handling, edge-case coverage, and resource cleanup (e.g., memory, file handles, connections).
- Correctness, type safety, and required tests.

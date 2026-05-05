---
name: design-seams
description: Design the natural seam for the current codebase and define its external contract and verification surface before implementation begins. Use when you want to decide the shape of a module, function, interface, route, or event contract before coding the internals.
license: MIT
compatibility: Claude Code, GitHub Copilot CLI
---

Design the natural seam for the current codebase before implementation begins.

A seam is the natural place where behavior is accessed and can vary, such as a function, module, interface, route, or event contract.

Define:

1. The seam to own
2. The external contract
3. The verification surface

For the external contract, specify the callable surface and the important expectations around it.

For the verification surface, specify the tests or checks that should prove the seam works from the outside.

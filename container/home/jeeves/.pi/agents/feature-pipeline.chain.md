---
name: feature-pipeline
description: Standard workflow for implementing features: architect → coder → reviewer
---

## architect
output: architecture.md
model: llama.cpp:local
thinking: high

Design the technical approach for {task}. Create a detailed implementation plan in architecture.md. Ask clarifying questions if needed, but escalate user-level decisions to the user rather than guessing.

## coder
reads: architecture.md
output: implementation.md
model: llama.cpp:local
thinking: medium

Implement the feature based on the architect's plan. Use browser-tools to verify functionality. If you encounter ambiguities in the spec, ask the architect for clarification (escalate user-level decisions to the user).

## reviewer
reads: architecture.md, implementation.md
output: review.md
model: llama.cpp:local
thinking: high

Review the implementation against the architectural plan and code quality standards. Test in browser using browser-tools. If issues are found, provide specific feedback and auto-loop back to coder (escalate after 2-3 iterations on same issues or when major trade-offs emerge).

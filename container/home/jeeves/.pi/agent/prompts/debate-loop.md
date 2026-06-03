---
description: Run a proponent/critic debate loop to refine an implementation plan
argumentHint: "task description"
---

Run a proponent/critic debate loop until the critic agrees or you reach the round limit. Default is 5 rounds.

Use the `subagent` tool. You are the loop controller — child subagents must not run subagents or manage the loop.

## How It Works

**Round 1 (proposal):**
1. Ask the proponent to propose a plan: `"TASK: {task}\n\nPropose your implementation plan."`
2. Ask the critic to critique it: `"PROPOSAL ROUND 1:\n\n{plan}\n\nCRITIQUE this plan. Find flaws, suggest improvements, push for simplification."`

**Rounds 2–5 (revision):**
1. Ask the proponent to revise: `"REVISION ROUND {n}:\n\n{critic's critique}\n\nPrevious critiques (summary):\n{summary}\n\nRevise your plan to address these concerns."`
2. Ask the critic to review: `"REVISION ROUND {n}:\n\n{proponent's revision}\n\nPrevious critiques (summary):\n{summary}\n\nReview the revision. AGREE if concerns were addressed, or DISAGREE with follow-up critiques."`

Stop early if the critic AGREEs.

## Verdict

After each critic response, check the last line:
- Ends with `Verdict: AGREE` → plan accepted, stop
- Ends with `Verdict: DISAGREE` → continue (if rounds remain)
- No verdict line → treat as DISAGREE with a note

The proponent and critic are instructed to end their output with the verdict line.

## Context Management

Pass only the **most recent critique** plus a **concise summary of older critiques** (2–3 sentences each). This keeps prompts focused and avoids token bloat from full history.

## Stagnation Guard

Compare the proponent's revision to the previous version. If changes are minimal (e.g., cosmetic rewording with no substantive changes), stop early and return DISAGREE with a note.

## Round Counting

- Round 1 = initial proposal + critique
- Rounds 2–5 = revise + review pairs
- Total: 5 rounds maximum
- Early exit on AGREE returns the actual round count

## Summary

On completion, report:
- Verdict (AGREE / DISAGREE)
- Total rounds run
- Key improvements across rounds
- Remaining concerns (if DISAGREE)

Additional task description from the slash command invocation:

$@

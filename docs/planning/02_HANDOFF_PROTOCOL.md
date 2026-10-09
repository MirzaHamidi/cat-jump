# CatJump — Manager → Coder Handoff Protocol

Every coding session must begin from a written handoff following this structure.

The purpose is to prevent the coder AI from guessing game design, expanding scope, or touching unrelated systems.

---

# A. Pre-Handoff Manager Checklist

Before writing the coder prompt, the Game Manager must:

1. Inspect the current default branch.
2. Read the latest relevant scripts/scenes.
3. Read the latest planning documents.
4. Review the previous session result.
5. Confirm that the previous system passed Definition of Done.
6. Identify exactly one next primary system.
7. Resolve every design question required for that system.
8. Research technical/design references if uncertainty remains.
9. Define acceptance criteria before implementation begins.
10. Define what evidence the coder must return.

If the next system depends on an unresolved core design decision, do not hand it to the coder yet.

---

# B. Coder Session Handoff Template

Copy this structure for every implementation session.

## SESSION TITLE

`[Session ##] — [ONE SYSTEM NAME]`

## 1. Objective

One paragraph describing exactly what this session completes.

The objective must describe a system outcome, not a vague activity.

Bad:
- improve movement
- work on combat
- polish game

Good:
- implement double jump with one aerial use and reset on valid landing
- implement persistent run state across Climb/Fight scene transition
- implement bird spawning, warning, vertical descent, and cleanup without combat integration

## 2. Why This Is Next

Explain dependency order in 2–5 bullets.

Example:
- Energy cost requires a working double jump first.
- Fight transitions require persistent run state before combat outcomes can be applied safely.

## 3. Repository Facts

List exact relevant files and current behavior discovered from the repository.

Example:
- `Scripts/Player.gd` currently owns normal movement.
- `Scenes/Levels/core_climb_test.tscn` is the newer climb prototype.
- No production combat scene currently exists.

Never describe a file as existing unless the manager verified it.

## 4. Player-Facing Target Behavior

Describe what the player must experience when the system is done.

Use observable behavior, not implementation jargon.

## 5. Frozen Rules / Values

List all design values the coder is not allowed to change.

Examples:
- Fight HP = 3
- Overworld Lives start = 9
- Normal jump Energy cost = 0
- Double jump Energy cost = [manager-frozen value]

If a value is still unknown and required for implementation, the handoff is not ready.

## 6. Technical Contract

Define the intended responsibility boundaries.

Examples:
- `Player.gd` may request Energy spend but must not own combat-scene loading.
- encounter transition must carry an `EncounterReason`.
- Fight HP must not reuse `overworld_lives`.
- bird collision may request one encounter only.

Avoid over-prescribing exact code structure when multiple clean implementations are possible, but be strict about ownership and state boundaries.

## 7. Allowed Change Surface

List files/folders the coder is expected to modify.

Example:
- `Scripts/Player.gd`
- one new Energy/session script
- one Energy HUD scene
- production gameplay scene references as required

The coder may touch another file only if necessary and must explain why.

## 8. DO NOT CHANGE

Mandatory list.

Examples:
- do not redesign jump feel outside parameters required by this system
- do not add inventory
- do not add procedural generation
- do not replace placeholder art with unrelated art packs
- do not alter combat rules during a bird-spawner session
- do not remove existing coyote time/jump buffer without a documented bug reason

## 9. Required Edge Cases

List edge cases for this exact system.

Examples for Energy:
- Energy exactly equals double-jump cost
- Energy is below cost
- multiple jump inputs in one frame/window
- landing resets only intended jump state
- transition begins exactly once at zero

Examples for bird:
- player already entering Fight Mode
- bird exits screen without collision
- repeated collision callbacks
- multiple active birds if allowed/not allowed
- spawn while player is respawning

## 10. Acceptance Criteria

Use binary, testable statements.

Example:
- [ ] player can perform exactly one double jump per airborne cycle
- [ ] successful double jump spends Energy exactly once
- [ ] normal jump never spends Energy
- [ ] Energy zero creates exactly one encounter request
- [ ] landing resets double jump availability
- [ ] existing coyote/jump-buffer behavior still works

If acceptance criteria are subjective, add measurable test conditions.

## 11. Required Test Procedure

Specify exact manual or automated tests.

Example:
1. Start a fresh run.
2. Perform 10 normal jumps and verify Energy unchanged.
3. Perform 5 double jumps and record Energy after each.
4. Reach zero Energy.
5. Verify only one transition request occurs.
6. Restart and verify default Energy restored.

## 12. Required Evidence From Coder

Coder must return:

- changed files
- concise implementation summary
- test results
- known issues
- screenshot/video path if available and useful
- commit SHA if committed
- any deviation from planned architecture

“Implemented successfully” is not evidence.

## 13. Regression Checklist

Select relevant existing systems:

- [ ] normal movement
- [ ] normal jump
- [ ] coyote time
- [ ] jump buffer
- [ ] camera
- [ ] floor tracking
- [ ] Energy
- [ ] Overworld Lives
- [ ] fight transition
- [ ] combat
- [ ] bird hazards
- [ ] timer
- [ ] restart
- [ ] victory
- [ ] Game Over

## 14. Out of Scope For This Session

Explicitly remind the coder what not to do.

## 15. Completion Rule

State:

> Do not begin another feature. Stop after this system is implemented, tested, and documented. Return results to the Game Manager for review.

---

# C. Manager Review Template

After the coder returns, the Game Manager must perform a review using this exact structure.

## SESSION REVIEW — `[Session ##] [System]`

### Verdict

Choose exactly one:

- `PASS — NEXT SYSTEM UNBLOCKED`
- `PASS WITH DOCUMENTED NON-BLOCKING LIMITATION`
- `FAIL — REPAIR REQUIRED BEFORE NEXT SYSTEM`

### Repository Evidence Reviewed

- commit SHA
- changed files
- current source inspection
- test evidence
- screenshots/video if applicable

### Acceptance Criteria

Copy every criterion from the original handoff and mark:

- PASS
- FAIL
- NOT PROVEN

`NOT PROVEN` is not equivalent to PASS.

### Regression Results

List each regression area checked.

### New Risks / Technical Debt

Only record real observed risks. Do not create speculative backlog filler.

### Planning Document Updates

Record any planning files changed because implementation reality differs from the previous plan.

### Next Session Status

- unblocked / blocked
- reason

---

# D. Repair Session Rule

If a completed system later regresses, the next session is a repair session, not a new feature session.

Repair handoff must:

- identify the regression
- identify the last known working behavior/commit when possible
- restrict changes to repair scope
- include a regression test that prevents recurrence

The roadmap pauses until repaired.

---

# E. Manager Handoff Quality Standard

A handoff is good enough when a competent coding AI can answer all of these before changing code:

- What exactly am I building?
- Why now?
- Which existing files matter?
- What must the player experience?
- What values/rules are fixed?
- What state belongs to this system?
- What state does not belong to this system?
- What can I edit?
- What must I not edit?
- What edge cases must work?
- How will success be tested?
- What evidence must I return?
- Where do I stop?

If any answer is unclear, the manager must improve the handoff before coding begins.

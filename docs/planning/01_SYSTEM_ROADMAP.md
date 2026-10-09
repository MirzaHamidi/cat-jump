# CatJump — System Roadmap

> **Status: superseded draft (2026-10-09).** This earlier 28-session outline is retained for history only. Implementers must follow the current 18-session sequence in `06_DEVELOPMENT_ROADMAP.md`; do not execute or combine sessions from this file. Current game rules and decisions are in `02_GAMEPLAY_SYSTEM_SPEC.md`, `03_TURN_BASED_COMBAT_SPEC.md`, and `10_MASTER_DECISIONS.md`.

This roadmap is intentionally organized as **one primary system per coder session**.

The manager may reorder sessions only when repository reality or a discovered dependency requires it. Any reordering must be documented.

A later session may not begin until the previous system passes its Definition of Done and regression review.

---

# Phase 0 — Production Baseline

## Session 0 — Production Gameplay Scene Baseline

### Goal
Establish one authoritative gameplay scene and retire the split between the old platform test and the newer four-column climb prototype.

### Why first
Every later system needs a stable production scene to integrate into.

### Expected work
- inspect `project.godot`
- inspect `Scenes/Levels/game.tscn`
- inspect `Scenes/Levels/core_climb_test.tscn`
- identify reusable pieces
- choose/construct the production gameplay shell
- make the chosen scene the clear integration target
- preserve existing responsive movement behavior
- preserve floor/progress tracking only if reliable

### Definition of Done
- game boots into the intended production gameplay scene or an explicitly documented menu-to-game path
- player can move/jump normally
- camera behavior is stable
- at least the baseline climb route works
- no duplicate active production gameplay architecture remains ambiguous
- docs record retired vs active prototype files

---

# Phase 1 — Core Traversal Resource Loop

## Session 1 — Double Jump System

### Goal
Implement a robust second aerial jump without Energy integration yet if separating those concerns produces a cleaner test.

### Required behavior
- one normal grounded jump
- one allowed double jump per aerial cycle
- landing resets aerial jump availability
- jump input buffering/coyote behavior does not create accidental extra jumps
- scene transitions cannot leave stale double-jump state

### DoD
- no triple jump
- no duplicate second-jump trigger from one input
- clear placeholder feedback for the second jump
- regression: normal jump feel remains good

---

## Session 2 — Energy Resource + Double Jump Cost

### Goal
Add Energy as an authoritative run resource and make successful double jump consume it exactly once.

### Required before coding
Manager freezes:
- max Energy
- double-jump cost
- UI representation
- zero threshold

### Required behavior
- visible Energy
- Energy spends only when the second jump successfully fires
- normal jump remains free
- Energy cannot go below intended bounds
- reaching zero emits a clean event/request for encounter transition instead of embedding fight-scene code inside `Player.gd`

### DoD
- repeated double-jump testing matches exact cost
- insufficient-Energy behavior is documented
- Energy state survives the architecture expected for Fight Mode transition
- zero event emits once

---

# Phase 2 — Persistent Run State and Scene Transition

## Session 3 — Game Session State

### Goal
Create one authoritative persistent model for run-level data.

### Required data
- Energy / max Energy
- Overworld Lives, starting at 9
- current floor/progress
- safe respawn floor/anchor representation
- run timer state
- encounter reason
- minimal return-to-climb context

### Architectural rule
Do not put all global state into the player node. Use a deliberate session/state owner appropriate for Godot.

### DoD
- scene changes do not reset run state unexpectedly
- state has clear ownership
- default/new-run initialization is explicit
- restart resets correctly
- no Fight HP stored as if it were Overworld Lives

---

## Session 4 — Climb-to-Fight Transition Pipeline

### Goal
Build safe transition plumbing independent of full combat rules.

### Required behavior
- Climb Mode can request an encounter with a reason
- current climb state is captured
- player/world input and simulation cannot continue in a harmful way during transition
- Fight Mode placeholder scene opens
- Fight Mode placeholder can return a test result
- Climb Mode resumes at the intended state

### Test encounter reasons
- Energy depletion
- Bird collision placeholder trigger if needed for pipeline test

### DoD
- no duplicated scene transitions
- no player falling several floors while combat is open because the world kept running incorrectly
- encounter reason survives transition
- return works repeatedly

---

# Phase 3 — Turn-Based Combat

## Session 5 — Turn-Based Combat Core

### Goal
Implement the smallest complete turn-based combat ruleset approved by the manager.

### Manager must freeze before handoff
- player actions
- enemy action logic
- player damage values
- enemy damage values
- enemy HP or equivalent defeat state
- turn order
- whether defend/dodge exists
- exact end-of-combat conditions

### Hard constraints
- player Fight HP = exactly 3
- encounter should be short
- no RPG expansion systems

### DoD
- fight begins at documented state
- player takes turns correctly
- enemy takes turns correctly
- player can win
- player can lose
- Fight HP cannot exceed or bypass documented rules
- combat returns a structured result, not arbitrary scene-specific side effects

---

## Session 6 — Energy Encounter Resolution

### Goal
Connect Energy depletion to the completed combat system and apply the correct victory/loss result.

### Manager must resolve before handoff
- post-loss Energy state
- exact 4–5 floor penalty selection rule
- safe respawn anchor logic

### Victory
- Energy restored to full
- climb resumes correctly

### Loss
- drop approximately 4–5 floors according to frozen rule
- safe respawn
- no zero-Energy retrigger loop

### DoD
- win tested
- loss tested
- repeated losses tested
- floor 1 / low-floor edge case tested
- state persists correctly across repeated encounters

---

# Phase 4 — Modular Vertical Traversal

Traversal elements should be completed one family at a time if they require distinct behavior. Purely visual variants can share a session only if they do not add independent mechanics.

## Session 7 — Window / Ledge Production Instance

### Goal
Make the baseline window scene production-safe and reusable.

### DoD
- correct one-way landing behavior
- predictable collision
- clear safe landing area
- compatible with respawn-anchor policy where needed
- visual placeholder readability

---

## Session 8 — AC Unit Traversal Instance

### Goal
Create/finish the outdoor AC unit as a reliable modular foothold.

### DoD
- collision matches visible top surface
- no snagging/phantom collision
- placement constraints documented
- SVG/vector placeholder is replaceable

---

## Session 9 — Pipe Traversal Instance

### Goal
Implement the approved pipe behavior without accidentally creating a whole new climbing-control system.

### Manager decision required
Choose the smallest viable interaction:
- narrow landing surface, OR
- a very simple dedicated pipe interaction if absolutely necessary

### DoD
- interaction is readable
- no hidden movement mode complexity beyond approved scope
- route authoring constraints documented

---

## Session 10 — Fire Escape Traversal Instance

### Goal
Complete reusable fire-escape platform/stair behavior.

### DoD
- supports the existing player controller
- collision is visually honest
- no bespoke animation dependency required for basic traversal
- authoring guidance documented

---

# Phase 5 — Bird Hazard

## Session 11 — Bird Spawn and Movement System

### Goal
Create the real-time descending bird hazard without fight integration yet.

### Manager freezes before handoff
- spawn interval range
- horizontal spawn rules
- speed range or fixed speed
- telegraph duration
- protected/no-spawn states

### Required behavior
- randomized but fair spawn
- top-to-bottom fast movement
- telegraph before dangerous contact if required by balance
- cleanup/recycling after leaving play area

### DoD
- no impossible/unavoidable spawn patterns in tested configurations
- no spawn during forbidden states
- no runaway node accumulation

---

## Session 12 — Bird Collision Encounter Integration

### Goal
Make a bird collision transition into Fight Mode exactly once.

### Required behavior
- one collision = one encounter
- triggering bird cannot retrigger after return
- encounter reason is Bird Collision
- world resumes cleanly

### DoD
- repeated bird encounters work
- collision during edge states does not duplicate transition
- bird cleanup verified

---

## Session 13 — Bird Fight Outcome + 9-Life Penalty

### Goal
Complete bird encounter consequences.

### Victory
- return to climb
- no Overworld Life loss
- Energy behavior follows approved rule

### Loss
- subtract exactly 1 Overworld Life
- if >0, safe resume according to approved respawn rule
- if 0, Game Over

### DoD
- 9→8 tested
- 1→0 tested
- no accidental Energy-encounter floor-drop rule applied unless explicitly approved
- Fight HP remains independent

---

# Phase 6 — Run Timer and Outcome Screens

## Session 14 — Run Timer

### Goal
Track completion time consistently through climb/fight transitions.

### Manager freezes
- exact combat time semantics
- pause/menu semantics if pause exists

### DoD
- no reset on fight transition
- no double-count
- restart resets
- victory freezes final time
- Game Over freezes final time

---

## Session 15 — Game Over Flow

### Goal
Create a complete run-loss flow for 0 Overworld Lives.

### DoD
- gameplay input stops appropriately
- result state is readable
- restart/new-run path works
- all run-state values reset correctly

---

## Session 16 — Victory / Reach-the-Top Flow

### Goal
Finish the finite climb with a clear top-of-building goal and result.

### DoD
- top trigger cannot fire accidentally early
- victory ends gameplay safely
- result screen shows at minimum completion + run time + lives remaining
- restart/new-run works

---

# Phase 7 — Authored Level / Building Progression

## Session 17 — Level Authoring Data Contract

### Goal
Define how finite floors/routes are represented without forcing full procedural generation.

Possible implementation forms:
- authored row data
- reusable height chunks
- scene-based floor groups
- lightweight resources/data describing instance placement

Manager/coder should choose the smallest maintainable option.

### DoD
- designers can author progression without editing core movement code
- required traversal instance types are supported
- safe respawn anchors can be identified
- floor numbering is reliable

---

## Session 18 — Intro + Early Difficulty Band

### Goal
Author and test the first teaching section of the climb.

No new mechanic is introduced in this session beyond arranging already completed systems.

### DoD
- teaches normal jump first
- introduces double jump safely
- demonstrates Energy consequence clearly
- route is completable without hidden knowledge

---

## Session 19 — Bird Introduction Band

### Goal
Author the first bird-teaching section.

### DoD
- first bird encounter is readable
- player has safe learning room
- no unavoidable collision
- later examples increase pressure gradually

---

## Session 20 — Combined / Late Climb Band

### Goal
Author the higher-pressure section using already-complete mechanics.

### DoD
- difficulty comes from combinations, not surprise new controls
- Energy decisions matter
- bird timing and traversal geometry remain fair
- no mandatory double jump sequence can soft-lock a player at impossible Energy state without intended encounter recovery

---

# Phase 8 — Feedback / Placeholder Presentation

## Session 21 — Climb HUD

### Goal
Make required state readable.

At minimum:
- Energy
- Overworld Lives
- floor/progress
- run timer

### DoD
- values update correctly
- no confusion between Overworld Lives and Fight HP
- readable at target resolution

---

## Session 22 — Fight HUD + Combat Feedback

### Goal
Polish readability of the already-complete combat system.

At minimum:
- 3 Fight HP
- enemy state/HP
- current turn
- action affordances
- hit/miss/damage feedback as applicable
- win/loss feedback

---

## Session 23 — Placeholder Visual Pass

### Goal
Replace unclear temporary geometry with consistent SVG/vector placeholder assets while preserving mechanics.

### Rule
This is not final art production.

### DoD
- silhouette/readability improved
- no collision changed accidentally to match decorative art unless specifically tested
- assets remain replaceable

---

# Phase 9 — Audio / Feel / Polish

## Session 24 — Core SFX Feedback

### Goal
Add only gameplay-critical sound feedback first.

Examples:
- normal jump
- double jump
- Energy spend/zero
- bird warning/pass/collision
- fight hit
- fight win/loss
- life lost
- victory

---

## Session 25 — Movement Feel Polish

### Goal
Tune existing movement values with completed level geometry.

Focus:
- jump arc
- acceleration
- air control
- double-jump impulse
- landing response
- camera

Do not rewrite working architecture merely for style.

---

## Session 26 — Encounter Pacing / Balance

### Goal
Tune Energy economy, bird frequency, fight duration, and floor-loss penalty as one balance review after all underlying systems already exist.

This is a balance session, not a new-feature session.

---

# Phase 10 — QA and Release Candidate

## Session 27 — Full Regression QA

Required matrix:
- fresh run
- Energy fight win
- Energy fight loss
- multiple Energy fights
- bird fight win
- bird fight loss
- bird loss at 1 Overworld Life
- scene transitions repeated many times
- low-floor 4–5 floor penalty
- restart from Game Over
- restart from Victory
- timer correctness
- double-jump Energy accounting
- all traversal instance collision checks

No new features.

---

## Session 28 — Final Scope Cut + Release Candidate

Goal:
- remove dead prototype paths where safe
- remove debug-only behavior not needed for release
- confirm main scene/export settings
- document remaining known limitations
- create final build candidate

No speculative feature additions.

---

# Definition of Done — Global

Every system session must satisfy all applicable items:

- one primary system only
- existing relevant repo files inspected before editing
- behavior matches the authoritative game scope
- edge cases handled
- no known soft lock
- no duplicate event trigger
- no regression in completed systems
- placeholder feedback sufficient to test behavior
- tuning values exposed/documented where useful
- test procedure executed
- evidence recorded
- changed files listed
- result handoff written
- planning docs updated if implementation reality changed

If any item fails, the system remains **INCOMPLETE**.

# CatJump — Game Manager AI Operating Contract

## Purpose

This file defines the operating contract for the Game Manager AI responsible for planning, research, scope control, and coder handoffs for CatJump / **Human Must Never Know**.

The Game Manager is **not** the implementation coder unless explicitly instructed otherwise. Its primary job is to inspect the current repository, maintain the planning documents, resolve design dependencies before implementation begins, and produce one tightly scoped coder handoff per development session.

The project is intentionally narrow. The manager must protect scope aggressively.

---

## Core Product Definition

CatJump is a finite vertical arcade-climbing game built in Godot 4.7.

The player controls a cat climbing from the bottom of an apartment exterior to the top by jumping between modular traversal instances such as:

- windows / window ledges
- pipes
- outdoor AC units
- fire-escape platforms
- fire-escape stairs
- balcony-like ledges when useful

The run alternates between two gameplay modes:

1. **Climb Mode** — real-time platforming and hazard avoidance.
2. **Fight Mode** — short turn-based encounters triggered by specific events.

The game must remain small enough to finish and polish. Do not expand it into an RPG, roguelike, metagame, open-ended procedural platformer, or content-heavy campaign.

---

## Locked Design Rules

These are authoritative. The manager may improve implementation details but may not silently change these rules.

### Traversal

- The cat climbs upward through a finite building/run.
- Normal jump is available without an energy cost.
- A double jump exists.
- Double jump consumes Energy.
- Energy is a persistent Climb Mode resource.
- If Energy reaches zero as a result of gameplay, the run transitions to Fight Mode.
- Movement feel must remain responsive and arcade-like. Existing coyote time, jump buffering, variable jump height, air control, and fall gravity are valuable baseline behavior and should not be casually removed.

### Energy-triggered fight

- Energy depletion triggers a turn-based fight.
- If the player wins that fight, Energy is restored to full and climbing resumes.
- If the player loses that fight, the cat is penalized by being moved approximately 4–5 floors downward.
- The manager must define a safe, deterministic post-loss respawn rule before coder implementation.
- IMPORTANT: a loss cannot return the player to Climb Mode with Energy still at zero in a way that immediately retriggers the same fight. The manager must explicitly define the post-loss Energy/grace-state contract before this system is coded.

### Bird hazard

- Birds are real-time Climb Mode hazards.
- A bird can appear at a randomized time.
- The intended bird motion is a fast vertical descent from the top of the active play area toward the bottom.
- The hazard must be avoidable by player movement rather than functioning as unavoidable RNG damage.
- If the cat avoids the bird, no fight occurs and the player loses no encounter time.
- If the cat collides with the bird, the game transitions into Fight Mode.
- If the player loses a bird-triggered fight, one Overworld Life is removed from the run's 9-life pool.
- Bird collision must trigger only one encounter, never repeated encounters from the same bird instance.

### Life model

There are two separate health/life concepts and they must NEVER share the same variable or UI meaning:

1. **Overworld Lives**
   - Start with 9.
   - Persist across the run.
   - Losing a bird-triggered fight removes 1 Overworld Life.
   - At 0 Overworld Lives the run ends in Game Over.

2. **Fight HP / Fight Lives**
   - The cat has exactly 3 Fight HP in a turn-based encounter.
   - Fight HP exists only inside Fight Mode.
   - Each new fight begins from the documented combat start state. Default planning assumption: 3/3 Fight HP unless a later approved rule says otherwise.
   - Fight HP is not the 9-life pool.

### Turn-based combat scope

Combat must remain a compact interruption to the climbing loop, not a second full game.

The manager must design and document a minimal combat ruleset before coder implementation. Constraints:

- exactly 3 player Fight HP
- short encounters
- clear win/loss condition
- small number of player actions
- reusable for at least Energy-depletion and Bird encounters
- no inventory system
- no equipment system
- no skill tree
- no elemental matrix
- no crafting
- no large status-effect framework
- no loot economy
- no dialogue tree required for the combat system

The manager should prefer a system that can be fully understood by a new player in one encounter.

### Visual scope

- Character and environment art are placeholders for now.
- Placeholder assets should use SVG/vector art and/or simple Godot-drawn primitives where practical.
- Do not spend implementation sessions on final art production before mechanics and state transitions are stable.
- Placeholder visuals still need good readability: player, traversal surfaces, hazards, fight UI, and interactable states must be instantly distinguishable.

### Run timing

The game should track total run time so that avoiding unnecessary fights has a meaningful time advantage.

Default planning rule unless explicitly revised in an approved design decision:

- run timer begins at gameplay start
- run timer ends on victory or final game over
- entering Fight Mode costs run time
- the manager must document whether the timer actively ticks during the fight scene or applies an equivalent encounter time cost

The coder must not invent timing behavior independently.

---

## Existing Repository Reality

The current repository contains multiple prototype directions. The manager must inspect the current default branch before every major planning revision.

Known current structure includes:

- `Scripts/Player.gd` — movement prototype
- `Scripts/ClimbingCamera.gd` — climbing camera prototype
- `Scripts/BuildingScroller.gd` — pooled four-column window climb prototype
- `Scenes/Levels/game.tscn` — older manually placed platform test scene and current project main scene
- `Scenes/Levels/core_climb_test.tscn` — newer four-column climbing prototype
- `Scenes/Gameplay/WindowRow.tscn`
- `Scenes/Gameplay/StandardWindow.tscn`
- placeholder special-window scenes
- modular environment placeholder scenes for AC, balcony, pipe, fire escape, etc.

The manager must explicitly distinguish:

- old prototype code that can be retired
- reusable prototype code
- production-target systems

Do not allow both prototype architectures to evolve indefinitely in parallel.

---

## Manager Responsibilities

### 1. Repository audit

Before planning a system, inspect all relevant current scripts/scenes and recent commits. Planning must describe what actually exists, not what a previous chat claims exists.

### 2. Maintain authoritative planning files

The manager owns the following documents:

- `docs/planning/00_GAME_SCOPE.md`
- `docs/planning/01_SYSTEM_ROADMAP.md`
- `docs/planning/02_HANDOFF_PROTOCOL.md`
- `docs/planning/03_REFERENCE_LIBRARY.md`

Update them when approved design decisions change.

### 3. One completed system per coder session

Every coder session must target exactly one primary system.

A session may touch supporting files only when necessary to complete that system.

Do not hand the coder a giant multi-system sprint.

Examples of valid single-system sessions:

- Double Jump + Energy Consumption
- Game Session State Persistence
- Fight Scene Transition Contract
- Turn-Based Combat Core
- Bird Hazard Spawner
- Bird Collision Encounter Integration
- Modular Pipe Traversal Instance

Examples of invalid handoffs:

- “finish player, combat, birds, UI and polish”
- “make the whole game”
- “add whatever is missing”

### 4. Perfect before expanding

A system is not complete because it visually appears once.

Before moving to the next system, the manager must require evidence that the completed system:

- works on the intended main gameplay path
- handles its important edge cases
- does not break existing completed systems
- has no known soft lock
- has no known duplicate-trigger bug
- has no placeholder TODO required for basic correctness
- has readable placeholder feedback
- has documented tunable parameters where appropriate
- has a clear test procedure
- has a coder handoff/result note

If a previous system is broken, the next feature session is blocked until regression repair is complete.

### 5. Scope protection

Any proposed feature not required by the locked core loop should default to **Out of Scope**.

The manager may create a `Later / Optional` note, but optional features must never silently enter the implementation roadmap.

---

## Architecture Principles the Manager Should Enforce

The manager should plan around explicit scene/state boundaries rather than hard-wiring every system into `Player.gd`.

Expected conceptual layers:

### Game Session State

Persistent run data, for example:

- current Energy
- max Energy
- Overworld Lives (9 max/start)
- current floor / progress index
- safe respawn floor/anchor
- run timer
- current encounter trigger reason
- pending fight outcome destination

### Climb Mode

Owns:

- player movement
- double jump
- Energy spend
- traversal collisions
- hazards
- floor/progress tracking
- climb HUD

### Fight Mode

Owns:

- 3 Fight HP
- enemy fight state
- player turn
- enemy turn
- actions
- win/loss resolution

### Transition / Resolution Layer

Owns safe conversion between the two modes:

- why the fight was triggered
- what happens on victory
- what happens on loss
- whether Energy is restored
- whether an Overworld Life is removed
- whether the player is moved down floors
- where the player respawns
- cleanup of the triggering hazard

This separation is critical. Do not scatter fight-result rules across bird scripts, player movement, HUD, and combat scene independently.

---

## Required Manager Research

The manager should research before finalizing architecture or balancing decisions. It must use legitimate sources and summarize principles instead of copying copyrighted book text.

Priority topics:

1. responsive platformer movement and game feel
2. finite vertical level pacing
3. telegraphing fast hazards fairly
4. encounter interruption cost and pacing
5. small turn-based combat design
6. balancing Energy cost against double-jump utility
7. state machines / scene transitions
8. event-driven decoupling in Godot
9. object pooling for repeated level pieces/hazards where justified
10. QA for cross-scene persistent state

The curated starting library is in `docs/planning/03_REFERENCE_LIBRARY.md`.

---

## Manager Decision Rules

When design information is missing:

1. First check this file and the planning documents.
2. Check the actual repository implementation.
3. Research relevant design/technical references.
4. Prefer the smallest solution that preserves the intended player experience.
5. Record the decision and rationale in planning docs.
6. If the decision would materially change the locked game fantasy/core loop, mark it as **USER DECISION REQUIRED** instead of inventing it.

Do not ask for approval for tiny implementation details. Do not invent major mechanics.

---

## Mandatory Coder Handoff Contents

Every session handoff must contain:

1. **Session title** — one system only.
2. **Why this system is next** — dependency reason.
3. **Current repository facts** — exact relevant files/scenes/scripts.
4. **Target player behavior** — what the player should experience.
5. **Exact rules** — values/contracts known at planning time.
6. **Implementation boundaries** — what files/systems may be changed.
7. **Do not change** list.
8. **Edge cases**.
9. **Acceptance criteria**.
10. **Testing procedure**.
11. **Evidence required from coder**.
12. **Regression checklist**.
13. **Out-of-scope reminders**.
14. **Post-session result template**.

The handoff must be sufficiently concrete that another coding AI can execute it without guessing game-design rules.

---

## Mandatory Post-Session Result

After the coder finishes a session, the manager must review the result and record:

- commit / changed files
- implemented behavior
- tests performed
- screenshots/video evidence if available
- known issues
- regressions checked
- parameter values changed
- whether Definition of Done passed
- whether the next system is unblocked

Never advance the roadmap based only on “implemented” or “should work.”

---

## Initial Open Design Questions the Manager Must Resolve Before Relevant Coding

These are deliberately not silently guessed:

1. Exact finite building length / floor count. Initial planning target may use ~50 floors, but the manager should verify pacing against traversal metrics before freezing it.
2. Exact Energy maximum and double-jump Energy cost.
3. Whether any action other than double jump spends Energy.
4. Energy state after losing an Energy-depletion fight. It must prevent immediate infinite fight retrigger.
5. Exact 4–5 floor loss rule: fixed, random 4/5, or context based.
6. Bird warning/telegraph duration and spawn fairness constraints.
7. Bird-fight victory Energy behavior.
8. Bird-fight loss respawn position in addition to losing 1 Overworld Life.
9. Minimal combat action set and enemy rules.
10. Whether the run timer literally continues during fights or receives an equivalent fixed/actual encounter-time cost.
11. Production gameplay scene migration: how/when `core_climb_test.tscn` replaces the older `game.tscn` prototype.

Each question must be resolved before the coder session that depends on it.

---

## Explicitly Out of Scope Unless the User Later Adds Them

- open world
- endless mode as the primary release structure
- procedural building generation as a release requirement
- inventory
- equipment
- crafting
- skill trees
- character classes
- multiple playable characters
- large dialogue system
- branching narrative
- complex NPC AI
- large enemy roster
- elemental/status combat framework
- loot system
- economy/shop
- online multiplayer
- online backend
- achievements
- battle pass
- cosmetics store
- metaprogression
- multiple buildings/biomes required for MVP
- final production art before mechanics are stable

The manager's job is to finish a small game, not to manufacture a backlog large enough to frighten future archaeologists.

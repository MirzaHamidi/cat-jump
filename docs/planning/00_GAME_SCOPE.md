# CatJump / Human Must Never Know — Earlier Game Scope Draft

Status: **Retained early draft; superseded by the current planning package**
Engine: **Godot 4.7**
Target: **small, finite, polished arcade game**

> **Authority note (2026-10-09):** This file was committed to `origin/main` while the comprehensive planning session was in progress. Keep it for history and context, but do not use its unresolved questions or values as implementation requirements. The current authority is `00_GAME_VISION_AND_SCOPE.md`, `02_GAMEPLAY_SYSTEM_SPEC.md`, `03_TURN_BASED_COMBAT_SPEC.md`, and especially `10_MASTER_DECISIONS.md` for resolved values.

---

## 1. High Concept

The player controls a cat climbing the exterior of an apartment building from bottom to top. The climb is a responsive real-time platforming challenge built from reusable traversal instances. The cat has an Energy resource tied primarily to double jumping. Running out of Energy interrupts the climb with a short turn-based fight. Random fast-descending bird hazards can also force a fight when the player fails to dodge them.

The central tension is:

> climb quickly and efficiently, spend Energy only when useful, avoid unnecessary fights, recover from mistakes, and reach the top before wasting too much time or too many lives.

The game is **not** intended to become a large RPG. The turn-based combat is a compact consequence/recovery system inside an arcade climbing game.

---

## 2. Core Player Loop

1. Spawn at the bottom of the building.
2. Jump upward through traversal instances.
3. Use normal jump freely.
4. Use double jump when needed, spending Energy.
5. Make continuous upward progress through floors/height bands.
6. Avoid descending bird hazards.
7. If Energy reaches zero, transition to an Energy-depletion Fight.
8. If a bird collides with the cat, transition to a Bird Fight.
9. Resolve the fight.
10. Apply the encounter-specific result.
11. Return to the climb.
12. Reach the top of the finite building to win.

---

## 3. Gameplay Modes

### 3.1 Climb Mode

Real-time gameplay.

Player can:

- move horizontally
- normal jump
- double jump if rules allow
- land on and move between traversal instances
- avoid hazards
- gain floor/height progress

Climb Mode owns the player's world position, current floor/progress, Energy, hazard interactions, and traversal physics.

### 3.2 Fight Mode

Turn-based gameplay.

Fight Mode is entered only through a documented encounter trigger.

Fight Mode owns:

- player Fight HP: exactly 3
- enemy combat state
- player turn
- enemy turn
- combat actions
- win/loss condition
- presentation of combat result

Fight Mode must remain short and readable.

### 3.3 Transition / Resolution

A dedicated encounter-resolution contract decides what happens when Fight Mode ends.

The same combat scene/system may be reused, but outcome rules depend on `EncounterReason`.

Suggested conceptual enum/data value:

- `ENERGY_DEPLETION`
- `BIRD_COLLISION`
- future encounter reasons only if explicitly approved

---

## 4. Player Movement Contract

Existing movement feel is considered useful baseline behavior.

Expected baseline:

- horizontal acceleration/deceleration
- air control
- coyote time
- jump buffering
- variable jump height / jump cut
- stronger falling gravity than rising gravity
- maximum fall speed

### Normal Jump

- free
- no Energy cost
- primary traversal action

### Double Jump

- usable after leaving the supporting surface according to the final movement-state implementation
- spends Energy
- must give clear audiovisual feedback even during placeholder phase
- cannot silently spend Energy multiple times from one input
- must obey a documented Energy cost

### Landing

Manager/coder must define when double-jump availability resets.

Default expected rule: a valid landing on a traversal surface resets aerial jump state.

---

## 5. Energy System

Energy exists to make double jump a strategic recovery/route-choice tool instead of a permanently free second jump.

### Locked rules

- double jump consumes Energy
- Energy persists during Climb Mode
- Energy reaching zero causes a transition to an Energy-depletion fight
- winning that fight restores Energy to full

### Required tuning values before implementation freeze

- `MAX_ENERGY`
- `DOUBLE_JUMP_COST`
- whether Energy is discrete chunks or a continuous numeric meter
- whether any mechanic other than double jump spends Energy

### Critical loss-state rule

If the player loses an Energy-depletion fight, the cat moves down approximately 4–5 floors.

The manager must define the post-loss Energy state so the game cannot immediately retrigger the same zero-Energy fight on returning to Climb Mode.

Valid small-scope solutions include, for example:

- restore a minimum recovery amount on loss
- restore full Energy but apply the floor penalty
- temporary encounter retrigger grace state

The manager must choose and document one before coding. The coder cannot invent one independently.

---

## 6. Overworld Lives vs Fight HP

These systems are intentionally separate.

### Overworld Lives

- run begins with 9
- persistent across the climb
- bird-fight loss removes 1
- 0 means Game Over

### Fight HP

- exactly 3 in each turn-based fight
- local to combat
- not the same as Overworld Lives
- default start is 3/3 per encounter

Recommended naming convention to prevent implementation confusion:

- `overworld_lives`
- `fight_hp`
- `fight_max_hp = 3`

Do not call both values `lives` inside shared code.

---

## 7. Energy-Depletion Fight Outcome

### Trigger

Energy reaches the documented zero threshold.

### Victory

- exit Fight Mode
- restore Energy to full
- resume climb from the correct saved traversal position/state

### Loss

- exit Fight Mode
- apply a 4–5 floor progress penalty
- respawn on a known safe traversal anchor
- apply the documented post-loss Energy rule
- do not soft-lock or immediately retrigger combat

The exact 4/5-floor selection method is a pending manager decision.

---

## 8. Bird Hazard

Bird is the first required active Climb Mode hazard.

### Spawn behavior

- appears at randomized times within documented min/max interval rules
- enters from the top side of the active play space
- descends quickly on a primarily vertical axis
- uses a collision/detection area appropriate for hazard contact
- is removed/recycled after leaving the relevant area

### Fairness requirements

The bird must be dangerous but readable.

Manager should define:

- telegraph/warning time
- legal spawn horizontal positions/lanes
- minimum reaction window
- whether a bird may spawn during unsafe states such as scene transition, respawn, or immediate post-fight control lock

Randomness must not create unavoidable hits.

### Avoided bird

- no combat
- no life loss
- no encounter time cost
- run continues

### Collision

- freeze/resolve world interaction safely
- mark encounter reason as Bird Collision
- consume/despawn/disable the triggering bird so it cannot retrigger
- enter Fight Mode

### Bird Fight Victory

- resume climb
- preserve or alter Energy only according to the documented rule
- do not lose an Overworld Life

### Bird Fight Loss

- remove 1 Overworld Life from the 9-life pool
- if lives become 0: Game Over
- otherwise resume at the documented safe respawn state
- exact respawn floor/position is a required planning decision

---

## 9. Turn-Based Combat Scope

Combat must be deliberately small.

### Required

- exactly 3 player Fight HP
- enemy health/state
- turn order
- small player action set
- enemy response
- readable damage feedback
- win state
- loss state
- encounter result callback/data

### Strong scope target

Aim for encounters that usually resolve in roughly 15–30 seconds once the player understands the rules.

### Prohibited expansion for MVP

- inventory
- consumable item bag
- equipment
- armor stats
- leveling
- XP
- skill tree
- elemental weaknesses
- status-effect framework
- complex party system
- large enemy roster
- loot tables
- shops

The manager must research and define the minimal combat action set before its coder session.

---

## 10. Traversal Instance Library

The building should be assembled from reusable scenes rather than one giant manually drawn collision map.

Required/expected traversal instance categories:

### Window / Window Ledge

- common baseline foothold
- readable landing surface
- one-way platform behavior where appropriate

### Pipe

- narrow traversal element
- exact interaction can be static landing surface or climb-support element only if explicitly designed
- do not invent a full ledge-grab/climbing animation system unless approved

### Outdoor AC Unit

- compact solid foothold
- clear top landing surface

### Fire Escape Platform

- larger safe landing/rest surface

### Fire Escape Stair

- traversal geometry that visually connects height changes
- mechanics must remain compatible with the simple platformer controller

### Balcony / other ledge

- optional within existing asset kit
- only used if it improves route readability without adding a new control system

Each instance should define:

- collision contract
- visual bounds
- safe landing area
- lane/placement constraints
- whether it can serve as a respawn anchor

---

## 11. Building / Level Structure

Release structure is finite.

The exact floor count is not frozen yet.

Planning target: approximately **50 floors** until traversal metrics and playtest pace justify a different number.

### Recommended progression structure

The manager should author difficulty bands rather than pure random generation.

Example planning bands:

- Intro: teach normal movement and safe traversal
- Early: introduce deliberate double-jump use
- Mid: introduce meaningful Energy pressure
- Hazard introduction: teach bird telegraph and avoidance
- Combined: Energy route choice + birds
- Late: denser but fair combinations
- Final climb: highest execution pressure without introducing a brand-new core mechanic
- Top: victory sequence

The actual band boundaries must be based on the final floor count.

### Procedural generation

Not required for MVP.

Existing pooling/recycling code may be reused technically, but the release experience should prioritize authored, predictable, testable progression.

---

## 12. Timer / Time Cost

The run should track completion time.

Purpose:

- avoiding birds matters
- entering fights has a measurable cost
- efficient climbing is rewarded
- playtests can compare pacing objectively

Manager must define one of these before final implementation:

A. total timer literally continues during Fight Mode, or
B. total timer pauses visually but combat duration is added to run time on resolution

Do not use both.

No hard time-limit fail condition is required unless later explicitly approved.

---

## 13. Placeholder Art Policy

During system development:

- SVG/vector placeholders are acceptable and preferred
- Godot Polygon2D/Line2D/simple shapes are acceptable
- art must communicate gameplay state clearly
- placeholder art should be modular and replaceable

Required readable placeholders include:

- cat
- normal traversal elements
- Energy meter
- 9 Overworld Lives UI
- Fight HP UI
- bird
- enemy placeholder
- fight actions/buttons
- damage feedback
- victory/game-over state

Do not block mechanical progress waiting for final illustration/animation assets.

---

## 14. State That Must Persist Across Scene Changes

At minimum:

- Energy/max Energy
- Overworld Lives
- current progress/floor
- safe respawn anchor/floor
- run time
- encounter reason
- necessary return-to-climb context

Fight HP should normally be fight-local unless a future approved rule changes that.

Do not serialize temporary bird node references or scene-local collision objects as persistent run state.

---

## 15. Major Failure Modes to Prevent

- Energy zero retriggers endless fight loop after a loss
- bird enters multiple fights from one collision
- world continues simulating and player falls while Fight Mode is active
- return from Fight Mode loses player progress unexpectedly
- fight HP decrements Overworld Lives directly
- bird-fight loss applies Energy-depletion floor penalty by accident
- Energy fight loss applies bird life penalty by accident
- player respawns inside collision or in an impossible route
- double jump charges Energy more than once per successful double jump
- double jump remains available infinitely after state transitions
- timer duplicates time or stops permanently after scene change
- pooled floor numbers desynchronize from actual progress
- old `game.tscn` and new climbing prototype both become competing production scenes

---

## 16. MVP Win / Loss

### Victory

Reach the top of the finite building.

Result screen should eventually show at least:

- completion
- total run time
- Overworld Lives remaining

### Game Over

Primary locked loss condition:

- Overworld Lives reach 0

Additional fall/recovery rules may be specified later, but should not introduce unnecessary life systems.

---

## 17. Out of Scope

See `GAME_MANAGER.md` for the full scope exclusion list.

In short, do not turn this into a progression-heavy RPG, procedural roguelike, multiplayer title, or content factory.

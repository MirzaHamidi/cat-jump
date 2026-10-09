# Human Must Never Know - Game Vision and Scope

Status: authoritative production plan, prepared 2026-10-09. Numeric rules are governed by 10_MASTER_DECISIONS.md.

## Story premise

The player is a cat who lives with its human on the top floor of a 1000-floor plaza. Before leaving for work, the human tells the cat not to cause trouble. The cat secretly leaves the home after the human and spends the day wandering around. Near sunset, the cat realizes the human will soon return from work. There is no safe route back home, so the cat must climb the outside of the plaza, using the facade and its windows to get back to the top before the human arrives and discovers what happened.

The title **Human Must Never Know** refers to this race: the cat must make it home before its human and keep the day's disobedience secret.

## Pitch

A cat races back toward its home at the top of a 1000-floor plaza before its human returns from work. With no safe way back, it climbs the outside facade using windows and other building traversal pieces, spends a limited Energy reserve for an extra midair leap, and dodges clearly signaled birds. Empty Energy or a bird collision interrupts the climb with a short, predictable turn-based fight. Reach the planned run's rooftop goal before all nine Overworld Lives are lost.

## Player fantasy

Be a nimble, mischievous cat desperately trying to cover up its day out before its human gets home. The fantasy comes from responsive movement, readable danger, the choice between a safe route and a quicker one, and the story pressure of secretly racing home. No human NPC gameplay or stealth subsystem is required by the current production plan.

## Design pillars

1. **A jump should feel dependable.** Horizontal air control, coyote time, jump buffering, and variable jump height are retained from the existing controller unless play evidence shows a concrete problem.
2. **Every danger is legible and avoidable.** Birds announce their lane before entering the play space. No random collision is accepted as fair.
3. **Risk is paid in understandable terms.** Normal jumps are free. Double jumps spend Energy. Fights cost active time. Losing costs five floors; a Bird fight also costs one Overworld Life.
4. **The building is a hand-authored place.** Finite floor groups and reusable scene instances remain editable in the Godot 2D editor.
5. **The Editor is the source of truth.** Major objects, collisions, hierarchy, and tuning values are visible in scenes and the Inspector.

## Core loop

1. Read the next ledge and hazard.
2. Move, jump, and land on a higher traversal surface.
3. Save Energy for a difficult recovery or shortcut; do not need it to follow the safe route.
4. Avoid a warned bird or resolve the short fight it causes.
5. Reach floor 50, or lose all nine Overworld Lives to Bird fights.

### Mode loop

- **Climb Mode:** real-time movement, one optional Energy-costed double jump per airborne sequence, manually placed traversal, bird warnings, floor progression, nine Overworld Lives, and an active run timer.
- **Fight Mode:** a brief two-action turn-based encounter. Climb simulation freezes; the run clock continues.
- **Terminal mode:** Victory or Game Over displays a final run summary and stops the clock.

## Win and loss

- **Victory:** land on the rooftop goal after reaching floor 50. Stop bird spawning and the run clock; show final time and highest floor.
- **Game Over:** lose the ninth Overworld Life in a Bird-triggered fight. Stop the clock and show final time, highest floor, and a retry choice.
- Energy-fight defeats are setbacks, not Game Over. Bird-fight defeats remove one Life and also use the shared five-floor knockback.

## Target length and difficulty

The first production layout is **50 numbered climb tiers**. A tier is the HUD/design unit used by this prototype, not a claim about architectural storey height or the full 1000-floor fiction. Target a first successful run of **2-4 minutes** and a practiced clean run of roughly **90-150 seconds**. These are design targets; Session 12 must measure real play before the values are treated as validated.

Difficulty ramps through spatial variety, optional Energy shortcuts, narrowing landing surfaces, and Bird timing. It does not ramp by increasing enemy stats, adding systems, or making the safe path impossible.

## Scope

In scope: responsive climbing; free normal jump; Energy-limited double jump; persistent run Energy and Lives; two short fight reasons; deterministic turn rules; bird telegraph and avoidance; 50 manually authored tiers; a HUD; timer; victory and Game Over; pause; small audio and visual cues; placeholder geometry.

The first control target is keyboard and mouse, matching the existing A/D movement and Space jump actions. Add W for pipe climbing, Z/X for Scratch/Brace, and Escape for pause. Menus and combat buttons remain clickable. Touch controls are outside this planning scope.

## Explicitly out of scope

No required procedural generation, endless primary mode, inventory, equipment, crafting, loot, shop, economy, skill tree, character classes, RPG stat builds, multiple playable characters, large enemy roster, multiple campaigns, multiplayer, backend, achievements, battle pass, cosmetic economy, or large dialogue system. No custom engine, ECS, event bus, reflection framework, or generated mega-scene.

## Difficulty and fair-play rules

- Floors 1-5 teach the normal jump with wide, stable windows and no Birds.
- Floors 6-10 introduce optional double-jump use and show that a normal-jump route remains.
- Floors 11-20 add the pipe and AC-unit choices; the first Bird warning is permitted only after floor 16 and a warm-up.
- Floors 21-40 combine the existing traversal vocabulary and occasional Birds. Every tier has a normal-jump route.
- Floors 41-49 combine known patterns, keep a readable safe route, and make the final ascent more deliberate.
- Floor 50 is a safe rooftop finish. It introduces no new rule.

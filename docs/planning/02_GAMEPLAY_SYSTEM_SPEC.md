# Human Must Never Know - Gameplay System Specification

Numeric values are authoritative in 10_MASTER_DECISIONS.md. This specification defines what those values mean.

## 1. Player movement

Production player is a reusable CharacterBody2D scene using the current Scripts/Player.gd logic. Movement continues to use move_and_slide() in _physics_process(). The initial tuning baseline is the values in the inspected script:

| Export | Initial value |
|---|---:|
| move_speed | 340 px/s |
| ground_acceleration / deceleration | 2400 / 3000 px/s^2 |
| air_acceleration / deceleration | 1650 / 1000 px/s^2 |
| normal jump_velocity | -610 px/s |
| coyote_time / jump_buffer_time | 0.12 / 0.12 s |
| jump_cut_multiplier | 0.45 |
| rising gravity / falling gravity | 1450 / 2300 px/s^2 |
| max_fall_speed | 1050 px/s |

Preserve horizontal acceleration, air control, jump buffering, coyote time, variable jump height, stronger falling gravity, and capped fall speed. Do not replace the controller with a new movement framework. Do not change values just to fit an unmeasured layout; adjust only after the jump envelope is observed in the game.

Normal jump is free. It is available while grounded or during the existing coyote window. A buffered ground jump may fire on landing.

## 2. Double jump and Energy

- The player may use one double jump after a normal jump has begun and before the next landing. The extra jump is not available just because the cat walked off a ledge after the coyote window expired.
- The second jump resets vertical velocity to the exported double-jump velocity. Initial planning value: -540 px/s.
- It costs 25 Energy. It does not consume or refresh the normal jump. Jump count resets after a confirmed landing.
- It can be used only once in an airborne sequence. The jump button press must be new; do not buffer a double jump or spend Energy from a held button.
- If Energy is below cost, the second jump is refused, no Energy is spent, and a short feedback cue says why. Do not trigger a fight because an unavailable action was attempted.
- Energy starts at 100. There is no passive regeneration, pickup, or cost for normal jump. Only Energy-fight victory fully restores it. Energy-fight defeat sets it to 50.
- The fourth successful double jump from full Energy reaches exactly zero. Reaching zero emits one depletion notification and asks RunController to start one Energy fight.
- Give an available double jump a brief lift pose/scale or ring plus a clear sound cue. These are feedback only, not another gameplay state.
- Keep Energy maximum and rules in RunState; do not duplicate them inside Player.gd.

## 3. Climb Mode and floor progress

- The production run is finite and contains floors 1-50. Floor 1 is the broad, safe starting landing; the first upward climb landing is floor 2. The HUD displays the current safe floor and the highest floor reached.
- Current floor changes after a successful landing on a higher or lower authored tier; highest floor only increases. An in-air jump does not award a floor before the landing.
- Each floor group in the scene has a readable name such as Floor_016. Platforms are direct scene instances under a floor group so designers can inspect each tier.
- ClimbLevel owns the four-column layout, camera, Player, traversal and bird systems. StandardWindow rows are manually authored in production even though the test harness reuses pooled rows.
- Every tier includes at least one safe route achievable with normal jumps. Double-jump paths can be shorter or recover an imperfect jump; they cannot be the only way through the main path.

## 4. Energy and encounter lock

RunState is the only owner of Energy and Overworld Lives. HUD only presents these values. Player requests Energy spend; it never starts or resolves a Fight itself.

All encounter requests enter one RunController method. If Energy is already zero when any request arrives, Energy is the selected reason even if a Bird request arrived first in the same physics frame. RunController then accepts only while in Climb Mode and with no active encounter, records the reason, locks the mode before responding to callbacks, and defers the scene/UI transition if the signal came during a physics callback. This closes duplicate-entry races.

On Energy reaching zero:
1. Complete the double-jump input/feedback for the already-paid action.
2. RunState emits one depletion event.
3. RunController records an Energy reason, changes to Fight Mode, disables ClimbLevel processing, stops the active bird warning, and displays Fight.
4. The run timer continues because RunState and the Fight UI remain active.
5. A Fight result resolves once, then the Fight scene is removed and ClimbLevel is resumed or respawned.

Energy cannot be reduced below zero. A second depletion event cannot replace a current encounter.

## 5. Bird hazard

BirdSpawner owns a Timer and a PackedScene reference to Bird. When the player first lands on floor 16, it starts a 25-second Climb-Mode warm-up. After that it runs one bird at a time. Each occurrence:

1. Select the next lane in a deterministic left-to-right cycle over four Inspector-assigned lane markers; after the right lane, return to the left. The cycle never selects an unreachable route at random.
2. Show an unmistakable warning at that lane for 1.5 seconds before spawning. Flash the lane/edge cue and play the warning cue.
3. Spawn a Bird 80 px above the active camera view after the warning. It falls vertically at 600 px/s.
4. If the player exits the marked lane, the bird passes without a fight, penalty, Energy change, or Life loss. The successful dodge saves active run time compared with the Fight path.
5. On player-body overlap, Bird disables its monitoring and emits one hit. BirdSpawner/ClimbLevel sends one Bird encounter request; the Bird then disappears. The RunController lock and the Bird's local triggered flag both prevent duplicates.
6. After a pass, schedule the next warning 35-45 seconds later. If a hit starts a Fight, cancel the warning/Bird; after a Fight return, schedule a fresh 35-45 second cooldown. Stop scheduling at floor 49.

The selected lane is not hidden randomness: the warning identifies the lane clearly enough that movement can avoid it. Birds are not spawned during the opening teaching floors or the final roof interaction. On first landing at floor 49, cancel a pending warning and despawn any live Bird; do not schedule another. Starting a fight clears any other pending warning.

## 6. Fight HP and Lives separation

Every Fight begins with 3 Fight HP, owned by FightController/Fight scene. Fight HP is reset for every encounter and never changes Overworld Lives. The 9 Overworld Lives live in RunState; they are removed only by a lost Bird-triggered Fight.

Energy-fight defeat does not cost a Life. Bird-fight defeat removes exactly one Life. At zero Lives the run ends immediately with Game Over.

## 7. Fight outcomes and respawn

A win in an Energy Fight restores Energy to 100 and resumes at the exact paused position/velocity; the current airborne double-jump remains spent until landing. A win in a Bird Fight leaves Energy and Lives unchanged and resumes at the paused position/velocity.

Every defeat uses one deterministic knockback rule: choose the authored safe anchor exactly five numbered floors below the last safely landed floor, clamped to floor 1. No random displacement. On Energy defeat, set Energy to 50 and do not remove a Life. On Bird defeat, remove one Life and leave Energy unchanged. If Bird defeat reaches zero Lives, show Game Over and do not respawn.

Each FloorTier contains one manually placed RespawnAnchor. The Marker2D position is the exact Player root position while safely standing there. On a nonterminal defeat: clear player velocity and jump timers; place the Player at the requested marker; update current floor; preserve highest floor; snap/reset the camera follow high-water mark; resume ClimbLevel after placement; grant 1.0 seconds of Bird-contact grace and restart the Bird cooldown. Energy is never zero on an Energy-defeat return, so no immediate Fight loop occurs.

## 8. Run timer and pause

Start the timer when a new run is launched from the title menu. It counts real gameplay delta in Climb and Fight, including short transition moments. It stops at Victory or Game Over. The timer pauses only when the game is paused (the pause menu or focus-loss pause); Fight Mode does not pause it. Retry starts a fresh timer, Energy, Life count, and floor record. No best-time persistence is required.

Display mm:ss.t on the run HUD and final summary. Keep elapsed time as a float in RunState; only format it at the presentation layer.

## 9. Victory and Game Over

The rooftop goal on floor 50 requests Victory once. It stops bird spawning and RunState's timer. Victory shows final time and highest floor, and offers Retry and Return to Title.

Game Over occurs only when a Bird fight defeat reduces Lives to zero. It stops the timer and displays final time, Lives (0), and highest floor. Retry creates a new run with default values; Return to Title leaves the finished run.

## 10. Transitions and edge cases

- A second bird hit, energy depletion, or callback received while mode is Fight/Paused/terminal is ignored.
- If Energy is at zero, the Energy Fight lock takes priority; no Bird can start concurrently.
- BirdSpawner cannot leave a live Bird or warning behind across Fight transitions.
- On Fight victory, restore the exact paused world; do not recreate the player or reset the camera.
- On Fight defeat, use an authored anchor; never teleport to an arbitrary pixel coordinate or into a collision shape.
- Reset velocity, jump buffer, coyote timer, double-jump flag, and pipe attachment during respawn.
- The floor display never decreases for the high-water record. A defeat lowers current floor only.
- An out-of-range floor target clamps to floor 1 and uses its known-safe anchor.
- The floor-50 goal must not fire multiple times while the player remains in its Area2D.
- A restart resets all run values and invalidates any previous encounter result.

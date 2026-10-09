# Human Must Never Know - QA and Regression Plan

This is the future implementation and release QA contract. No gameplay QA has been run as part of the planning session.

## QA layers

Every session uses all applicable layers; no single layer substitutes for the others.

1. **Code/scene verification:** parse project scripts, load changed scenes with the project's supported Godot 4.7 editor/runner, inspect signal connections and collision-layer/mask values. Add a small GDScript test scene only when it materially improves repeatability.
2. **Running-game verification:** run the actual Climb/Fight/UI path, not only a mocked method.
3. **Manual Editor verification:** open the affected .tscn; inspect the node tree, attached script, collision and exported values; change and restore a setting.
4. **Regression verification:** repeat the earlier system checks and compare resource/mode state before and after.

Automated tests are useful for exact Energy deltas, one-shot signals, fight turn order, floor penalty, Life count, and reset defaults. They do not replace a visible game run, collision debug view, or human Editor inspection. Keep any test harness small and Godot-native.

## Baseline and evidence

- Record the Godot editor/runner version used. The repository currently declares Godot 4.7 features and a 1280x720 viewport.
- Save a repeatable procedure and expected result for every failure fixed.
- Capture a scene-tree/Inspector image for new systems and runtime values for transitions.
- For a session, list exact changed paths and inspect the path-limited diff. Do not include preexisting modified scenes or generated untracked UID files without authorization.
- No clean run claim without startup/exit status, expected visible output, and no unexpected parser/runtime/teardown errors.
- On a full run, record completion result/time and whether the tester knew the next action at each Bird warning, fight intent, respawn, and terminal screen.

## Regression matrix

| ID | System | Procedure | Expected result |
|---|---|---|---|
| Q01 | Project entry | Run project from Editor. | MainMenu opens; no missing scene or script. |
| Q02 | Menu -> run | Press Start twice quickly. | Exactly one fresh Run and RunState; no duplicated world. |
| Q03 | Normal movement | Walk both directions, accelerate/stop, jump from ground and midair, release early/late. | Existing speed/air control, variable jump and fall cap remain. |
| Q04 | Coyote and buffer | Jump just after leaving a ledge; press jump just before landing. | Existing coyote and buffer windows work; no unintended second jump. |
| Q05 | Double jump | Jump, press jump again once; test grounded, held, repeated and post-landing input. | One extra jump after normal jump; one use per air sequence; regular jump free. |
| Q06 | Energy cost | Start at 100, do four double jumps on separate landed sequences. | Values 75, 50, 25, 0; normal jump unchanged; exactly one depletion event. |
| Q07 | Insufficient Energy | Set Energy below cost and press double jump. | No second jump and no spend/fight. |
| Q08 | Duplicate Energy trigger | Cause repeated zero notifications while Fight is active. | One Fight, one active reason, one result. |
| Q09 | Fight turn order | Scratch/Brace through STRIKE and RECOVER. | Exact 6 enemy HP, 3 Fight HP, 1 damage, deterministic alternating intent. |
| Q10 | Fight victory | Scratch six times and Brace on a Strike before third damaging response. | Victory once, final opponent hit causes no retaliation. |
| Q11 | Fight defeat | Scratch without a valid Brace through three damaging Strikes. | Fight HP reaches 0; one defeat result; no Life is changed inside Fight. |
| Q12 | Fight reset/separation | Run multiple fights; inspect Lives and Fight HP. | Fight HP starts at 3 each time; Lives remain their separate RunState value unless Bird loss resolves. |
| Q13 | Energy fight win | Deplete Energy, win Fight. | Climb resumes at exact position, velocity and camera; Energy=100, Life unchanged. |
| Q14 | Energy fight loss | Deplete Energy, lose Fight at floors 1, 6 and 12. | Safe anchor at max(1, landed floor-5); Energy=50; Lives unchanged; no immediate Fight. |
| Q15 | Camera restore | Lose fight at high floor, compare camera before/after return. | Camera snaps to the authored anchor and resets upward-follow reference; no long unintended camera sweep. |
| Q16 | Traversal collision | Walk/jump through and land on each one-way ledge. | Upward passage works; landing edges match visible art. |
| Q17 | Pipe | Enter, hold Up, stop, exit with left/right and jump; leave area. | Climb speed is Inspector-tunable; no gravity while attached; Energy and double-jump count not reset. |
| Q18 | Stair | Jump each one-way step from below. | Each step is physical, visible and reachable; decorative rails are not mistaken for collision. |
| Q19 | Floor progression | Land at floor 1, ascend, fall back, land on lower tier. | Current floor follows landing; highest floor never decreases; no floor awarded midair. |
| Q20 | Manual level edit | Move/duplicate/replace a floor instance and run. | ClimbLevel still works; no generator rebuild or hidden node creation is needed. |
| Q21 | Bird warning | Wait until floor16 and warm-up; inspect warning lane. | Warning lasts at least 1.5 seconds and identifies the incoming path. |
| Q22 | Bird dodge | Leave the marked lane before the Bird crosses the player band. | No Fight, Life loss, Energy penalty or floor drop; cooldown prevents immediate next hazard. |
| Q23 | Bird hit once | Allow one contact; hold player in Area2D/test duplicate callbacks. | Bird disables itself; one encounter request only. |
| Q24 | Bird victory | Win a Bird Fight. | Same climb position/velocity, unchanged Energy and Lives, Bird removed. |
| Q25 | Bird defeat | Lose one Bird Fight with Lives=2. | Lives 1, Energy unchanged, five-floor safe anchor drop. |
| Q26 | Zero Lives/Game Over | Lose Bird fight with Lives=1. | Lives 0, timer stops, Climb cannot resume, one Game Over. |
| Q27 | Retry | Retry from Game Over and Victory. | New RunState at Energy100/Lives9/floor1/timer0 and no old encounter. |
| Q28 | Run timer | Compare Climb, Fight, pause, Victory and Game Over. | Climb and Fight count; pause freezes; terminal states stop; final formatted time matches elapsed value. |
| Q29 | Pause/restore | Pause during warning, Fight and Climb; resume. | No active callbacks occur while paused; correct mode resumes; no stale warning or lost player. |
| Q30 | Victory | Reach floor50 and overlap rooftop goal twice. | One Victory, timer and Birds stop, final time displayed. |
| Q31 | Menu/terminal focus | Use keyboard navigation and mouse on all buttons. | Selected action is visible and repeatable; no blocked screen. |
| Q32 | Full run | Play through all floors without deliberate test cheats. | Reach one terminal result; no forced Energy jump, unavoidable Bird, missing floor or duplicate encounter. |

## Per-session regression gate

For every Roadmap session:
- Re-run the acceptance procedure.
- Re-run direct predecessor system tests listed in that session.
- Open the affected scene in Godot and inspect its hierarchy.
- Inspect current status and path-limited diff.
- Record pass/fail, actual values, and evidence.
- If a regression fails, stop and repair that system before another session.

## Collision review

Use Physics 2D collision debug visibility in the running Editor. Starting convention: world/player solid surfaces on physics layer 1; Area2D interaction/hazard regions on layer 2 and masking Player layer 1. Confirm the exact layer/mask in each scene rather than assuming names. Bird Areas detect Player; visible platforms collide with Player; UI has no world collision.

## Final release readiness

Release-ready means:
- Every production scene opens and runs in the supported Godot version.
- All Q01-Q32 applicable checks pass and are recorded.
- A first complete success run and a complete zero-Life failure run have both been played.
- No unexpected parser, physics, or teardown diagnostics remain.
- The user can inspect/tune Player, BirdSpawner, fight and traversal values in the Editor.
- The main climb is finite and manually authored, and current tests remain isolated.
- Physical-device or unfamiliar-player checks are reported honestly if they were not run.

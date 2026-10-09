# Human Must Never Know - Developer AI Roadmap

This is the ordered implementation contract. Complete one session, review it, and pass its regression gate before starting the next. Do not ask a Developer AI to build the whole game.

## Rules for every session

Use ordinary Godot 4.x development practices: Nodes, Scenes, GDScript, signals when they clarify ownership, exported tuning values, editor-authored collisions, and PackedScene instances for reusable/spawned objects. Keep the Scene dock understandable. No custom framework, ECS, universal bus, giant manager, reflection system, generated gameplay hierarchy, or unrelated rewrite.

**Human review gate, required after every session:** the user can (1) open Godot, (2) open the affected scene, (3) see the created nodes, (4) understand their names, (5) select them, (6) inspect scripts, (7) inspect and tweak exported values, (8) run the scene, (9) reproduce the feature, and (10) inspect a path-limited diff. If any step fails, the session is not done.

Do not broaden allowed files because a refactor seems cleaner. If acceptance or regression fails, repair this session before proceeding. Each Developer AI reports changed paths, tests run, manual steps and results, evidence, and remaining defects. Do not stage unrelated scene edits.

## Session 01 - Production Run Root and Menu Flow

- **Player-Facing Goal:** Press Start on the title screen and enter a new production run.
- **Why This Session Happens Now:** A separate production entry is needed before systems can be added without turning game.tscn or the scrolling test into the shipped game.
- **Dependencies:** Repository audit and this architecture.
- **Current Relevant Files:** project.godot; Scenes/Levels/main_menu.tscn; Scenes/Levels/game.tscn; Scenes/Levels/core_climb_test.tscn.
- **Nodes Involved:** MainMenu Node2D preserving existing title art, MenuUI CanvasLayer/Control, StartButton, QuitButton; Run Node2D; World; ClimbLevel shell; RunState placeholder; HUD/Fight/Outcome/Pause CanvasLayers.
- **Scenes Involved:** Move the existing Scenes/Levels/main_menu.tscn in the Godot Editor to canonical Scenes/UI/MainMenu.tscn; add Scenes/Levels/Run.tscn and Scenes/Levels/ClimbLevel.tscn.
- **Scripts Involved:** New Scripts/MainMenu.gd and Scripts/RunController.gd, each narrowly scoped.
- **New Nodes Expected:** Menu buttons, persistent run root and named empty layers. ClimbLevel shell contains Environment, Traversal, Hazards, Player and Camera anchors.
- **New Scripts Expected:** Scripts/MainMenu.gd and Scripts/RunController.gd.
- **Existing Files Allowed To Change:** project.godot; move Scenes/Levels/main_menu.tscn to Scenes/UI/MainMenu.tscn using the Editor; add Scenes/Levels/Run.tscn, Scenes/Levels/ClimbLevel.tscn, and their named scripts. Preserve the existing title art and UID; do not touch Scenes/Levels/game.tscn.
- **Systems That Must Not Change:** Player movement, camera math, test scenes, traversal collision, Energy/Fight/Bird rules.
- **Required Behavior:** Set the project entry to Scenes/UI/MainMenu.tscn. Start creates a fresh Scenes/Levels/Run.tscn; Quit exits cleanly. Run remains the parent of RunState and all mode layers. Do not implement gameplay here.
- **Inspector / Exported Parameters:** MainMenu exports the Run PackedScene. Scene-layer references are assigned in the Inspector or in the Run scene, not searched globally.
- **Signal Connections:** StartButton.pressed and QuitButton.pressed connect to MainMenu methods.
- **Edge Cases:** Missing run scene reports a clear error and keeps the menu usable; repeated Start presses cannot stack runs.
- **Acceptance Criteria:** Project boots to title; Start enters one visible run shell; no duplicate run root or autoload exists.
- **Test Procedure:** Run the project; click Start; return to title through the temporary development route if provided; click Quit and confirm clean exit.
- **Manual Godot Editor Verification:** Open Scenes/UI/MainMenu.tscn and Scenes/Levels/Run.tscn; select buttons/layers; inspect Scripts/MainMenu.gd and exported PackedScene; change button text and verify the running menu.
- **Regression Tests:** Confirm Scenes/Levels/core_climb_test.tscn still opens as an independent test; confirm MainMenu starts the production run and the project no longer boots Scenes/Levels/game.tscn.
- **Evidence Required:** Screenshot of menu and run shell, changed-path list, clean scene-load output, and manual start/quit result.
- **Definition of Done:** Human review gate passes; both scenes open and run; no gameplay feature is hidden in Scripts/MainMenu.gd or Scripts/RunController.gd; no important TODO remains.
- **Next Session Unblocked:** Player Scene and Movement Baseline.

## Session 02 - Reusable Player Scene and Movement Baseline

- **Player-Facing Goal:** Control the cat in the production world with the existing responsive movement.
- **Why This Session Happens Now:** Later abilities must extend a clear player scene rather than copies embedded in test rooms.
- **Dependencies:** Session 01.
- **Current Relevant Files:** Scripts/Player.gd; Scripts/ClimbingCamera.gd; Scenes/Levels/core_climb_test.tscn; Scenes/Levels/ClimbLevel.tscn.
- **Nodes Involved:** CharacterBody2D Player; CollisionShape2D; Sprite2D; Camera2D.
- **Scenes Involved:** New Scenes/Player/Player.tscn; Scenes/Levels/ClimbLevel.tscn; Scenes/Levels/core_climb_test.tscn only for regression.
- **Scripts Involved:** Existing Scripts/Player.gd and Scripts/ClimbingCamera.gd.
- **New Nodes Expected:** Reusable player root hierarchy and small temporary editor-authored floor/window geometry in ClimbLevel.
- **New Scripts Expected:** None.
- **Existing Files Allowed To Change:** Add Scenes/Player/Player.tscn; edit only the Player and Camera2D instances in Scenes/Levels/ClimbLevel.tscn.
- **Systems That Must Not Change:** Scripts/Player.gd movement constants/logic, camera follow rules, BuildingScroller, menu and run state.
- **Required Behavior:** Move Player from a test-room embedded node into Scenes/Player/Player.tscn without changing input or physics behavior. ClimbLevel uses one instance. The camera follows the instance.
- **Inspector / Exported Parameters:** Preserve existing movement exports exactly; set the target on ClimbingCamera in the Inspector.
- **Signal Connections:** None.
- **Edge Cases:** The player sprite and collision remain aligned despite the existing scene scale; missing camera target produces a useful warning, not a crash.
- **Acceptance Criteria:** Horizontal movement, normal jump, jump cut, coyote time, buffer, air control, gravity and fall cap behave like the existing test.
- **Test Procedure:** Run core_climb_test, then the production shell with temporary ground/windows; walk, jump, land and repeat from edges.
- **Manual Godot Editor Verification:** Open Scenes/Player/Player.tscn; inspect root/body/collision/sprite; select exports; adjust move_speed in Inspector and see the change; restore the agreed value.
- **Regression Tests:** Compare the movement feature list and exported baseline with the pre-session controller; confirm no movement value changed without evidence.
- **Evidence Required:** Player tree screenshot, export Inspector screenshot, test-scene and production-scene results, exact changed paths.
- **Definition of Done:** Human review gate passes; Player is one reusable scene; all existing movement qualities are preserved and no unrelated scene is staged.
- **Next Session Unblocked:** Run Session State and Timer.

## Session 03 - Run Session State and Timer

- **Player-Facing Goal:** A new run begins with the defined Energy/Lives/floor values and accumulates an elapsed time.
- **Why This Session Happens Now:** Persistent values need one visible owner before double jump, fights, HUD, and outcomes connect.
- **Dependencies:** Session 01; Session 02 player root may be present.
- **Current Relevant Files:** Scenes/Levels/Run.tscn; Scripts/RunController.gd; Scenes/Player/Player.tscn.
- **Nodes Involved:** RunState Node under Run; RunController; ClimbLevel reference.
- **Scenes Involved:** Scenes/Levels/Run.tscn; Scenes/Levels/ClimbLevel.tscn.
- **Scripts Involved:** New Scripts/RunState.gd; small additions to Scripts/RunController.gd only to call reset.
- **New Nodes Expected:** Scripted RunState child.
- **New Scripts Expected:** Scripts/RunState.gd.
- **Existing Files Allowed To Change:** Scenes/Levels/Run.tscn, Scripts/RunController.gd, new Scripts/RunState.gd.
- **Systems That Must Not Change:** Player movement, camera, scene menu, traversal, combat, Birds.
- **Required Behavior:** One reset method initializes Energy 100, maximum 100, Lives 9, current/highest floor 1, and elapsed seconds 0. RunController starts in Climb Mode with no active encounter. Elapsed gameplay time advances in Climb and Fight and stops in terminal mode; it is naturally paused with SceneTree pause.
- **Inspector / Exported Parameters:** Keep Max Energy, starting Energy, starting Lives and timer display interval visible on the RunState or controlled from one documented settings node; avoid duplicate constants.
- **Signal Connections:** energy_changed, lives_changed, floor_changed and timer_changed are emitted only when their displayed values change.
- **Edge Cases:** Reset called twice yields the same defaults; elapsed time never decreases; no negative Energy/Lives; timer signal does not fire at rendered-frame frequency.
- **Acceptance Criteria:** Remote Inspector values change correctly; fresh Run scene always resets; no Autoload is introduced.
- **Test Procedure:** Launch/restart scene; inspect RunState in Remote tree while running; pause the SceneTree in editor and confirm elapsed time holds; unpause and confirm it resumes.
- **Manual Godot Editor Verification:** Open Scenes/Levels/Run.tscn, select RunState and inspect all defaults/signals; adjust a safe test value, run, and restore it.
- **Regression Tests:** Start twice; ensure only one RunState exists; confirm menu start and movement still work.
- **Evidence Required:** Inspector/Remote tree screenshots, elapsed-time observation, changed paths.
- **Definition of Done:** Human review gate passes; session state is the sole owner of run values; timer behavior is visible and tested.
- **Next Session Unblocked:** Double Jump and Energy Spend.

## Session 04 - Double Jump and Energy Spend

- **Player-Facing Goal:** Use one additional midair jump at a clear Energy cost while regular jump stays free.
- **Why This Session Happens Now:** RunState exists to own Energy; combat can be integrated after the ability's exact spend conditions are correct.
- **Dependencies:** Sessions 02-03.
- **Current Relevant Files:** Scenes/Player/Player.tscn; Scripts/Player.gd; Scripts/RunState.gd; Scenes/Levels/core_climb_test.tscn.
- **Nodes Involved:** Player CharacterBody2D; RunState; simple jump-feedback child.
- **Scenes Involved:** Scenes/Player/Player.tscn; Scenes/Levels/core_climb_test.tscn.
- **Scripts Involved:** Scripts/Player.gd and Scripts/RunState.gd.
- **New Nodes Expected:** One small feedback node or AnimationPlayer only if it materially improves double-jump readability.
- **New Scripts Expected:** None unless feedback cannot remain in Scripts/Player.gd.
- **Existing Files Allowed To Change:** Scripts/Player.gd, Scenes/Player/Player.tscn, and Scripts/RunState.gd. Reuse the existing jump InputMap action; no project setting change is expected.
- **Systems That Must Not Change:** Normal jump rules/values, lives/timer, fight scene, camera, floor layout.
- **Required Behavior:** One double jump after an initiated normal jump; exported cost 25; start Energy 100; no regeneration; successful spend applies -540 px/s; landing refreshes one use. Unaffordable presses do nothing and spend nothing.
- **Inspector / Exported Parameters:** Player exposes double_jump_velocity and double_jump_cost; RunState exposes maximum/current values. Player passes its cost to RunState.try_spend_energy(amount).
- **Signal Connections:** RunState emits Energy change and one energy_depleted event at zero. Do not start Fight yet.
- **Edge Cases:** No double jump while grounded, on repeated held input, twice in one air sequence, after walking off with no normal jump, or with less than cost. Jump buffer remains for ground jumps only.
- **Acceptance Criteria:** Normal jump remains free; exactly four successful double jumps from 100 reach 0; fourth jump impulse still occurs; no duplicate depletion event.
- **Test Procedure:** Test grounded, coyote, buffer, one/two air presses, landing reset, held key, and insufficient Energy.
- **Manual Godot Editor Verification:** Select Player, change double jump cost/velocity in Inspector, reproduce one allowed and one refused jump, inspect RunState Energy.
- **Regression Tests:** Retest all baseline movement properties from Session 02.
- **Evidence Required:** Inspector values and a short capture or test log showing spend, refusal, landing reset, zero event count.
- **Definition of Done:** Human review gate passes; double jump is configurable and the normal controller remains readable.
- **Next Session Unblocked:** Turn-Based Combat Core.

## Session 05 - Turn-Based Combat Core

- **Player-Facing Goal:** Understand and win or lose one short Fight through Scratch and Brace.
- **Why This Session Happens Now:** Combat rules must exist and be independently tested before encounter wiring.
- **Dependencies:** Planning docs only; Session 03 Run root for optional layout context.
- **Current Relevant Files:** Scenes/Levels/Run.tscn; project.godot InputMap; docs/planning/03_TURN_BASED_COMBAT_SPEC.md.
- **Nodes Involved:** Fight Control root, opponent display, three player HP pips, six enemy pips, intent Label, Scratch and Brace Buttons.
- **Scenes Involved:** New Scenes/UI/Fight.tscn; Scenes/Levels/Run.tscn only for independent preview.
- **Scripts Involved:** New Scripts/FightController.gd.
- **New Nodes Expected:** Readable Fight UI and action buttons.
- **New Scripts Expected:** Scripts/FightController.gd.
- **Existing Files Allowed To Change:** Scenes/UI/Fight.tscn; Scripts/FightController.gd; project.godot only to add the named fight_scratch and fight_brace InputMap actions.
- **Systems That Must Not Change:** Energy/Lives, Climb/Player, timer, traversal, Bird.
- **Required Behavior:** Implement exactly the 3/6 HP, Strike/Recover cycle, 1 damage, Scratch and Brace ordering in 03_TURN_BASED_COMBAT_SPEC.md. Fight receives a reason and emits one result.
- **Inspector / Exported Parameters:** Export opponent display resources only if needed; gameplay constants stay declared once and readable, not hidden in data frameworks.
- **Signal Connections:** Button pressed signals connect to FightController; fight_finished(victory) emitted once.
- **Edge Cases:** Defeated opponent cannot retaliate; Brace disabled on Recover; no input after outcome; Fight HP resets per new instance.
- **Acceptance Criteria:** Clean play wins with one Brace at a Strike; no-Brace play loses on the third damaging Strike; bracing every Strike wins within 12 actions; hit/damage counts match.
- **Test Procedure:** Run Scenes/UI/Fight.tscn directly; play a win, loss, and repeated Brace path using mouse and keyboard.
- **Manual Godot Editor Verification:** Inspect the Control hierarchy, each pip, buttons, script and signal connections; change an HP display position and verify it remains editable.
- **Regression Tests:** Open/restart Fight multiple times; confirm no persistent Fight HP and no duplicate result signal.
- **Evidence Required:** Win/loss action transcript or short capture, scene tree and Inspector screenshots, logs and changed paths.
- **Definition of Done:** Human review gate passes; complete combat rules work in isolation without RunState mutations.
- **Next Session Unblocked:** StandardWindow and FloorTier Foundation.

## Session 06 - StandardWindow and FloorTier Foundation

- **Player-Facing Goal:** Climb one manually authored window tier and see the correct floor after landing.
- **Why This Session Happens Now:** The production climb needs explicit reusable ledges and floor metadata before 50-floor content is authored.
- **Dependencies:** Sessions 01-05.
- **Current Relevant Files:** Scenes/Gameplay/StandardWindow.tscn; Scenes/Gameplay/WindowRow.tscn; Scripts/BuildingScroller.gd; Scenes/Levels/ClimbLevel.tscn; Scenes/Levels/core_climb_test.tscn.
- **Nodes Involved:** FloorTier Node2D; Traversal and RespawnAnchor children; StandardWindow StaticBody2D; Player.
- **Scenes Involved:** Existing StandardWindow; new Scenes/Gameplay/FloorTier.tscn; Scenes/Levels/ClimbLevel.tscn.
- **Scripts Involved:** New Scripts/FloorTier.gd and Scripts/ClimbLevel.gd.
- **New Nodes Expected:** FloorTier scene root with exported floor_number; Traversal Node2D child; RespawnAnchor Marker2D child whose exact position marks the Player root's safe standing position.
- **New Scripts Expected:** Scripts/FloorTier.gd and Scripts/ClimbLevel.gd.
- **Existing Files Allowed To Change:** New Scenes/Gameplay/FloorTier.tscn and Scripts/FloorTier.gd; Scripts/ClimbLevel.gd and Scenes/Levels/ClimbLevel.tscn; Scripts/Player.gd only to emit one landing signal without changing movement; Scripts/RunState.gd only for floor_changed contract.
- **Systems That Must Not Change:** Scrolling recycler, movement values/behavior, Energy/fight rules, future hazards.
- **Required Behavior:** Manually instance a FloorTier and StandardWindow; detect a Player landing by walking its collision ancestor to the explicit FloorTier owner; update current/highest only on landing. Production is not auto-populated.
- **Inspector / Exported Parameters:** FloorTier exposes floor_number; StandardWindow collision stays a normal visible one-way CollisionShape2D.
- **Signal Connections:** Player.landed_on_surface(collider) -> ClimbLevel floor lookup -> RunState.floor_changed; no 50 editor connections required.
- **Edge Cases:** The starting platform is FloorTier 001 and initializes current/highest floor to 1; first upward landing is floor 2 and there is no floor 0. Falling never lowers highest floor; nested visual nodes do not mask owning FloorTier lookup.
- **Acceptance Criteria:** Duplicate one FloorTier in editor, change its number/position, and see that landing updates the correct floor.
- **Test Procedure:** Run ClimbLevel; jump between 2-3 instances; fall back and verify current/highest values.
- **Manual Godot Editor Verification:** Open FloorTier and StandardWindow scenes, inspect collision, floor export, parent path and one-way setting; move/duplicate an instance and reproduce landing.
- **Regression Tests:** Floor tracking does not modify the BuildingScroller test harness; a later session will verify it after Fight return.
- **Evidence Required:** Scene tree/Inspector screenshots; current/highest values for climb/fall/respawn.
- **Definition of Done:** Human review gate passes; floor identity is explicit editor data, not hidden name parsing or a generated table.
- **Next Session Unblocked:** Energy Fight Transition and Resolution.

## Session 07 - Energy Fight Transition and Resolution

- **Player-Facing Goal:** Energy reaching zero starts one Fight; victory restores climbing and loss safely returns the cat five floors down.
- **Why This Session Happens Now:** Combat and run state can now be integrated as one complete encounter loop.
- **Dependencies:** Sessions 01-06.
- **Current Relevant Files:** Scripts/RunController.gd; Scripts/RunState.gd; Scripts/Player.gd; Scenes/Levels/ClimbLevel.tscn; Scenes/UI/Fight.tscn; Scripts/ClimbingCamera.gd; Scenes/Gameplay/FloorTier.tscn.
- **Nodes Involved:** RunState, RunController, ClimbLevel, FightLayer, Player, Camera2D, RespawnAnchors.
- **Scenes Involved:** Scenes/Levels/Run.tscn, Scenes/Levels/ClimbLevel.tscn, Scenes/UI/Fight.tscn; ClimbLevel test fixture with labeled floor anchors.
- **Scripts Involved:** Scripts/RunController.gd, Scripts/RunState.gd, Scripts/ClimbLevel.gd, Scripts/ClimbingCamera.gd, Scripts/FightController.gd only for reason/result contract.
- **New Nodes Expected:** FightLayer instance during encounter; three temporary FloorTier test instances with safe anchors at floors 1, 6, and 12.
- **New Scripts Expected:** None; the FloorTier, ClimbLevel, RunState, RunController, and Fight scripts already exist from earlier sessions.
- **Existing Files Allowed To Change:** Scripts/RunController.gd, Scripts/RunState.gd, Scripts/ClimbLevel.gd, Scenes/Levels/ClimbLevel.tscn, Scripts/ClimbingCamera.gd, and Scripts/FightController.gd only for result handoff.
- **Systems That Must Not Change:** Fight turn/damage numbers, Player horizontal/normal movement, Bird system not yet created, level content.
- **Required Behavior:** On Energy zero, lock mode before deferred transition; freeze ClimbLevel but keep timer/Fight active. Victory sets Energy 100 and restores exact position/velocity/camera. Defeat sets Energy 50, leaves Lives, and moves to last landed floor minus five (clamp floor 1). Reset velocity/jump/pipe state; snap camera; grant Bird grace for later; unlock once.
- **Inspector / Exported Parameters:** FloorTier.floor_number is exported; each anchor stays a direct Marker2D child. RunController references RunState, ClimbLevel, and FightLayer visibly.
- **Signal Connections:** energy_depleted -> RunController; Fight fight_finished -> RunController; RunState node signals remain local.
- **Edge Cases:** Duplicate depletion/result ignored; zero-Energy defeat cannot immediately retrigger; fight victory in midair resumes same jump with its used-double-jump flag; anchors never place inside a platform.
- **Acceptance Criteria:** Forced Energy depletion enters one Fight; each result resolves once; victory restores 100; defeat returns at exact target anchor with 50; no life change or repeated Fight.
- **Test Procedure:** Use test Energy values via Inspector/Remote Inspector, reach zero, win and lose; repeat at floors 1, 6, and 12.
- **Manual Godot Editor Verification:** Inspect Run hierarchy, FightLayer, FloorTier anchors and floor values; select camera/player exports; move a test anchor and repeat respawn.
- **Regression Tests:** Retest combat core, Energy spend, timer runs through Fight, timer stops when paused.
- **Evidence Required:** Before/after values, target anchor coordinates/floors, camera view, one-win/one-loss result, relevant scene screenshots and paths.
- **Definition of Done:** Human review gate passes; no Fight/Climb scene replacement loses run state; defeat loop is impossible.
- **Next Session Unblocked:** Pipe Climb Interaction.

## Session 08 - Pipe Climb Interaction

- **Player-Facing Goal:** Hold Up inside a visible pipe to take a slower, safe vertical route.
- **Why This Session Happens Now:** The existing pipe already has a clear Area2D volume, and the interaction must be established before level placement.
- **Dependencies:** Sessions 02 and 06-07.
- **Current Relevant Files:** Scenes/Assets/Environment/PipeClimb.tscn; Scenes/Player/Player.tscn; Scripts/Player.gd; project.godot.
- **Nodes Involved:** PipeClimb Node2D, ClimbArea Area2D/CollisionShape2D, Player CharacterBody2D.
- **Scenes Involved:** Scenes/Assets/Environment/PipeClimb.tscn; Scenes/Player/Player.tscn; isolated climb test scene.
- **Scripts Involved:** New Scripts/PipeClimb.gd; Scripts/Player.gd.
- **New Nodes Expected:** None beyond visible Area2D signal ownership.
- **New Scripts Expected:** Scripts/PipeClimb.gd.
- **Existing Files Allowed To Change:** Scenes/Assets/Environment/PipeClimb.tscn; Scripts/PipeClimb.gd; Scripts/Player.gd; Scenes/Player/Player.tscn; project.godot only to add the named move_up InputMap action.
- **Systems That Must Not Change:** Normal jump tuning, Energy cost, combat, timer, floor rules.
- **Required Behavior:** Entering the climb area registers one active pipe; Up climbs at 160 px/s, gravity is suspended, releasing Up hangs safely, horizontal input or jump exits. Climbing costs no Energy and does not refresh double jump; jump out is a normal pipe-exit jump.
- **Inspector / Exported Parameters:** PipeClimb exports climb_speed (initial 160). Player exports no duplicate pipe speed.
- **Signal Connections:** ClimbArea body_entered/body_exited connects to PipeClimb methods; pipe calls small Player enter/exit methods through the known body reference.
- **Edge Cases:** Leaving the Area2D, overlapping two pipes, losing a pipe during encounter, and respawn all clear or replace the active reference safely.
- **Acceptance Criteria:** Pipe behavior is obvious, reliable and adjustable; no global group lookup or pipe manager.
- **Test Procedure:** Walk/jump into a pipe, climb, stop, detach by horizontal/jump, re-enter, and respawn.
- **Manual Godot Editor Verification:** Inspect ClimbArea collision and layer/mask; change speed in Inspector; duplicate/move pipe and reproduce.
- **Regression Tests:** Retest normal and double jump; pipe entry does not refill or double-spend Energy.
- **Evidence Required:** Pipe tree, speed export, input action, climb/detach and regression result.
- **Definition of Done:** Human review gate passes; pipe is one editable PackedScene and Player remains a focused script.
- **Next Session Unblocked:** AC, Fire Escape, and Balcony Traversal.

## Session 09 - AC, Fire Escape, and Balcony Traversal

- **Player-Facing Goal:** Use narrow AC landings, broad fire-escape rest platforms, short jumpable stairs, and balconies.
- **Why This Session Happens Now:** The mechanic vocabulary must have tested collision purpose before it is placed across the finite level.
- **Dependencies:** Sessions 07-08.
- **Current Relevant Files:** Scenes/Assets/Environment/ACUnit.tscn; Scenes/Assets/Environment/FireEscapePlatform.tscn; Scenes/Assets/Environment/FireEscapeStair.tscn; Scenes/Assets/Environment/Balcony.tscn; Scenes/Levels/ClimbLevel.tscn.
- **Nodes Involved:** StaticBody2D, Visual, CollisionShape2D, step StaticBody2D children.
- **Scenes Involved:** Existing four Environment scenes and a small traversal showcase/test scene.
- **Scripts Involved:** No new gameplay scripts expected.
- **New Nodes Expected:** FireEscapeStair receives individual visible one-way step bodies/shapes; other scenes retain their collision roots.
- **New Scripts Expected:** None.
- **Existing Files Allowed To Change:** Scenes/Assets/Environment/ACUnit.tscn; Scenes/Assets/Environment/FireEscapePlatform.tscn; Scenes/Assets/Environment/FireEscapeStair.tscn; Scenes/Assets/Environment/Balcony.tscn; optional new Scenes/Levels/traversal_collision_test.tscn. Leave the user-modified Scenes/Levels/asset_showcase.tscn untouched.
- **Systems That Must Not Change:** Player logic, Energy, Fight, Lives, floor state, Bird.
- **Required Behavior:** AC is a narrow 144 px landing; FireEscapePlatform is a broad 210 px landing; Balcony is a 200 px landing/rest point; stairs have actual jumpable steps rather than decorative Area2D-only volume.
- **Inspector / Exported Parameters:** Keep dimensions as CollisionShape2D resources/scene values visible; do not introduce a generic traversal data framework.
- **Signal Connections:** None required for static landings.
- **Edge Cases:** One-way collisions allow upward passage; step surfaces do not overlap in a way that blocks normal jumps; visual and collision edges match.
- **Acceptance Criteria:** Each object has a distinct traversal use, correct collision, and a safe normal-jump connection to/from a StandardWindow in the test scene.
- **Test Procedure:** Run the showcase/test; land on each object, jump through from below, and test each stair step.
- **Manual Godot Editor Verification:** Open each .tscn; select collision, adjust size/position, duplicate and move an instance; confirm it remains editable and visible.
- **Regression Tests:** Re-run StandardWindow and pipe routes; confirm no test scene or player movement values changed.
- **Evidence Required:** Per-scene node/collision screenshots and jump results.
- **Definition of Done:** Human review gate passes; all four scenes offer actual tested traversal, not decorative-only props.
- **Next Session Unblocked:** Finite Hand-Authored 50-Floor Level.

## Session 10 - Finite Hand-Authored 50-Floor Level

- **Player-Facing Goal:** Climb a complete, hand-authored route from the start to the roof.
- **Why This Session Happens Now:** All required traversal and floor metadata exist; content can now be assembled without procedural systems.
- **Dependencies:** Sessions 01-09.
- **Current Relevant Files:** Scenes/Levels/ClimbLevel.tscn; Scenes/Gameplay/FloorTier.tscn; Scenes/Gameplay/StandardWindow.tscn; Scenes/Assets/Environment/ACUnit.tscn; Scenes/Assets/Environment/PipeClimb.tscn; Scenes/Assets/Environment/FireEscapePlatform.tscn; Scenes/Assets/Environment/FireEscapeStair.tscn; Scenes/Assets/Environment/Balcony.tscn; Scenes/Levels/core_climb_test.tscn.
- **Nodes Involved:** Environment, Traversal, Floor_001 through Floor_050, Player, Camera2D, RespawnAnchors.
- **Scenes Involved:** Scenes/Levels/ClimbLevel.tscn; Scenes/Gameplay/FloorTier.tscn; Scenes/Gameplay/StandardWindow.tscn; and the existing Environment traversal scenes.
- **Scripts Involved:** Scripts/ClimbLevel.gd, Scripts/FloorTier.gd, Scripts/Player.gd, Scripts/ClimbingCamera.gd.
- **New Nodes Expected:** 50 FloorTier instances, hand-authored traversal instances, one safe anchor per floor, a start ground.
- **New Scripts Expected:** None.
- **Existing Files Allowed To Change:** Scenes/Levels/ClimbLevel.tscn and Scripts/ClimbLevel.gd. Instance the existing Scenes/Gameplay/StandardWindow.tscn and Scenes/Assets/Environment/*.tscn; do not modify those reusable scenes in this session. Never edit Scenes/Levels/core_climb_test.tscn to turn it into production.
- **Systems That Must Not Change:** Fight rules, Energy values, Bird timing, menu, and movement baseline. Solve reachability issues through layout changes in this session; record any proposed movement retune for Session 17.
- **Required Behavior:** Implement the ranges and fair placement rules in 04_LEVEL_DESIGN_AND_PROGRESSION.md. Keep one normal-jump safe path, visible landmarks every five floors, and a broad floor-50 rooftop. If a route is unreachable with the preserved controller, revise its authored layout and record the measurements instead of silently changing movement values.
- **Inspector / Exported Parameters:** Floor number is on each FloorTier scene; floor pitch/camera framing are visible scene/script exports only if truly needed.
- **Signal Connections:** ClimbLevel reports landed FloorTier to RunState; rooftop request may be a placeholder signal until Victory session.
- **Edge Cases:** Every jump has a safe landing; no floor group or anchor is missing/duplicate; falls/defeat preserve high-water record.
- **Acceptance Criteria:** Manual route from floor 1 to 50 is reachable; floors 1-5 teach; 6-10 show optional double jump; traversal types appear in planned ranges; fastest/safe route can be reproduced.
- **Test Procedure:** Play floor bands in order; perform normal jump, optional double jump, pipe, AC, stair, balcony and deliberate fall. Record time and unreachable transitions.
- **Manual Godot Editor Verification:** Open ClimbLevel; collapse/expand floors; select/move/duplicate/replace a traversal instance; change floor export; run and reproduce.
- **Regression Tests:** All previously implemented movement, energy-fight and traversal checks; floors 1/5/16/25/45/50 and each respawn anchor.
- **Evidence Required:** Screenshots of floor groups and representative detail, route play recording, missing-anchor checklist, elapsed time, changed paths.
- **Definition of Done:** Human review gate passes; all 50 tiers are editor instances and no level generation dependency remains.
- **Next Session Unblocked:** Bird Warning and Spawner.

## Session 11 - Bird Warning and Spawner

- **Player-Facing Goal:** See a fair lane warning and dodge a falling Bird before it can hit.
- **Why This Session Happens Now:** The complete route exists, including the floor-16 teach point.
- **Dependencies:** Sessions 01-10.
- **Current Relevant Files:** Scenes/Levels/ClimbLevel.tscn; Scripts/ClimbLevel.gd; Scripts/ClimbingCamera.gd; Scenes/Player/Player.tscn; Scripts/RunState.gd.
- **Nodes Involved:** BirdSpawner Node2D; Timer; lane warning UI/marker; Bird Area2D; CollisionShape2D; visual child; Player.
- **Scenes Involved:** New Scenes/Gameplay/Bird.tscn; Scenes/Levels/ClimbLevel.tscn; existing bird test scene.
- **Scripts Involved:** New Scripts/Bird.gd and Scripts/BirdSpawner.gd; Scripts/ClimbLevel.gd.
- **New Nodes Expected:** Bird scene; BirdSpawner Timer; four Marker2D lane children named Lane_01 through Lane_04; visible WarningCue CanvasLayer/Control.
- **New Scripts Expected:** Scripts/Bird.gd and Scripts/BirdSpawner.gd.
- **Existing Files Allowed To Change:** Scenes/Gameplay/Bird.tscn; Scripts/Bird.gd; Scripts/BirdSpawner.gd; Scenes/Levels/ClimbLevel.tscn; Scripts/ClimbLevel.gd; no separate HUD edit is needed because WarningCue belongs to BirdSpawner.
- **Systems That Must Not Change:** Fight rules, Energy spend, Life resolution, floor layout, player jump.
- **Required Behavior:** First landing on floor 16 starts a 25-second Climb-Mode warm-up. Then cycle Lane_01 to Lane_04, show the selected lane for 1.5 seconds, spawn 80 px above the camera at 600 px/s, and schedule the next warning 35-45 seconds after a pass or encounter return. Run only one Bird. On landing at floor 49, cancel a warning and remove a live Bird. Passing/dodging is free; collision emits a single hit request.
- **Inspector / Exported Parameters:** BirdSpawner exposes bird_speed (600), warning_duration (1.5), initial_warmup (25), interval_min/max (35/45), spawn_height (80), and Bird PackedScene. Lane markers are visible child nodes. Bird receives bird_speed at spawn and owns only its movement/contact behavior.
- **Signal Connections:** Timer.timeout -> BirdSpawner; Bird body_entered -> Bird; Bird hit/pass -> BirdSpawner/ClimbLevel.
- **Edge Cases:** SceneTree pause freezes the warning and Timer so the same warning resumes; an encounter cancels the pending warning and live Bird. Bird exits the camera world harmlessly; collision layer/mask sees Player only; no duplicate trigger.
- **Acceptance Criteria:** Every lane can be escaped with at least the warning time; Bird never damages or starts Fight during the opening 15 floors; dodge has no consequence.
- **Test Procedure:** Set short test delay in Inspector; verify warning, lane change, collision, pass, cooldown, pause and resume.
- **Manual Godot Editor Verification:** Inspect Timer, PackedScene, Area2D shape and exports; move marker and tune speed without opening script.
- **Regression Tests:** Repeat floor progression, Fight timer/freeze behavior, and normal jump after hazard pass.
- **Evidence Required:** Warning/collision/pass clips, timer values, collision debug screenshot, logs and changed paths.
- **Definition of Done:** Human review gate passes; hazard is telegraphed and avoidable, and it owns no run consequences.
- **Next Session Unblocked:** Bird Fight Resolution and Overworld Lives.

## Session 12 - Bird Fight Resolution and Overworld Lives

- **Player-Facing Goal:** A Bird collision causes one Fight; victory resumes cleanly, defeat costs one Life and five floors.
- **Why This Session Happens Now:** Bird hit requests, Fight scene, RunState, and safe anchors exist.
- **Dependencies:** Sessions 01-11.
- **Current Relevant Files:** Scripts/RunController.gd; Scripts/RunState.gd; Scripts/ClimbLevel.gd; Scripts/Bird.gd; Scripts/BirdSpawner.gd; Scripts/FightController.gd; Scenes/Gameplay/FloorTier.tscn.
- **Nodes Involved:** RunState, RunController, Bird, FightLayer, Player, Camera2D, anchors.
- **Scenes Involved:** Scenes/Levels/Run.tscn; Scenes/Levels/ClimbLevel.tscn; Scenes/Gameplay/Bird.tscn; Scenes/UI/Fight.tscn; Scenes/Gameplay/FloorTier.tscn.
- **Scripts Involved:** Scripts/RunController.gd, Scripts/RunState.gd, Scripts/ClimbLevel.gd, Scripts/Bird.gd, Scripts/BirdSpawner.gd.
- **New Nodes Expected:** None.
- **New Scripts Expected:** None.
- **Existing Files Allowed To Change:** Scripts/RunController.gd; Scripts/RunState.gd; Scripts/ClimbLevel.gd; Scripts/Bird.gd; Scripts/BirdSpawner.gd; Scripts/FightController.gd only if the existing result contract needs a connection; corresponding signal connections in Scenes/Levels/Run.tscn, Scenes/Levels/ClimbLevel.tscn, Scenes/Gameplay/Bird.tscn, and Scenes/UI/Fight.tscn.
- **Systems That Must Not Change:** Combat numbers/turn order, Energy cost/refill rules, traversal, timer rules.
- **Required Behavior:** Bird Fight win loses no Life/Energy and resumes exact state. Defeat loses exactly one of nine Lives, applies five-floor anchor drop, leaves Energy unchanged, and restarts hazard cooldown. At zero Lives set terminal Game Over state and stop the run; Game Over presentation comes in Session 15.
- **Inspector / Exported Parameters:** Overworld Lives defaults remain in RunState; floor penalty is one shared value, not a Bird-specific hidden value.
- **Signal Connections:** Bird hit -> ClimbLevel encounter request -> RunController; fight result -> RunState/ClimbLevel; lives_changed reaches future HUD.
- **Edge Cases:** Bird and Energy trigger same frame; only one reason wins. Zero Life emits one terminal event. A bird already in collision cannot hit after return.
- **Acceptance Criteria:** 9 to 8 on one Bird defeat; 1 to 0 ends run; Energy fight defeat removes no Life; all results resolve once.
- **Test Procedure:** Force Lives to 2 then lose twice; test Bird win, Bird loss, Energy loss, and hit while encounter lock is active.
- **Manual Godot Editor Verification:** Inspect RunState, Bird flag, encounter connections and target anchor; adjust test Lives in Inspector and reproduce each state.
- **Regression Tests:** Full combat and Energy-fight tests; timer includes Fight; Bird remains clear on a dodge.
- **Evidence Required:** Before/after Life and Energy values, floor/camera state, duplicate-trigger count, terminal event capture.
- **Definition of Done:** Human review gate passes; Fight HP and Overworld Lives remain separate in code and UI data.
- **Next Session Unblocked:** Run HUD and Pause.

## Session 13 - Run HUD and Pause

- **Player-Facing Goal:** Read Energy, Lives, floor, timer, and Fight HP at a glance; pause safely.
- **Why This Session Happens Now:** State and gameplay loops are connected; presentation can consume authoritative signals.
- **Dependencies:** Sessions 01-12.
- **Current Relevant Files:** Scripts/RunState.gd; Scenes/Levels/Run.tscn; Scenes/UI/Fight.tscn; Scenes/Levels/ClimbLevel.tscn; current FloorUI in Scenes/Levels/core_climb_test.tscn.
- **Nodes Involved:** HUD CanvasLayer/Control; Energy bar/label; nine Life icons; floor and timer labels; PauseMenu.
- **Scenes Involved:** New Scenes/UI/HUD.tscn and Scenes/UI/PauseMenu.tscn; Scenes/UI/Fight.tscn.
- **Scripts Involved:** New Scripts/HUD.gd and Scripts/PauseMenu.gd; Fight UI only for visual consistency.
- **New Nodes Expected:** Visible HUD controls and pause/resume buttons.
- **New Scripts Expected:** Scripts/HUD.gd and Scripts/PauseMenu.gd.
- **Existing Files Allowed To Change:** Scenes/UI/HUD.tscn; Scenes/UI/PauseMenu.tscn; Scripts/HUD.gd; Scripts/PauseMenu.gd; Scenes/Levels/Run.tscn; Scenes/UI/Fight.tscn only for layout coordination; project.godot only to add `pause` mapped to Escape.
- **Systems That Must Not Change:** RunState values, combat math, movement/hazard difficulty, encounter outcomes.
- **Required Behavior:** Show Energy/current maximum, 9 separate Overworld Lives, current/highest floor and mm:ss.t timer; Fight UI separately displays 3 Fight HP. Pause freezes climb, Fight and timer and offers Resume/Restart/Title. Losing window focus enters the same paused state and requires explicit resume.
- **Inspector / Exported Parameters:** HUD receives a RunState reference; layout/color/text sizes are editable in scene/theme, not generated at runtime.
- **Signal Connections:** RunState value signals -> HUD; pause button/input -> PauseMenu; resume -> unpause.
- **Edge Cases:** Zero/maximum Energy visible; zero Lives terminal has no pause/resume; focus navigation and mouse both work; pause doesn't leave Bird warning active.
- **Acceptance Criteria:** All resources can be read without mixing Lives and Fight HP; timer pauses only under pause, not Fight; no UI covers unavoidable movement cues.
- **Test Procedure:** Run, pause/resume during Climb and Fight, test focus loss, reach Energy 0, view timer and all values.
- **Manual Godot Editor Verification:** Open HUD/Pause/Fight scenes; select and restyle a bar/icon, inspect scripts/signals, run and reproduce.
- **Regression Tests:** Energy, Bird, combat, floor and timer values match source of truth after UI updates.
- **Evidence Required:** HUD screenshots in Climb/Fight/Pause, timer pause/resume observation, UI tree and path diff.
- **Definition of Done:** Human review gate passes; UI only displays rules and pause does not mutate gameplay state.
- **Next Session Unblocked:** Victory Screen.

## Session 14 - Victory and Rooftop Goal

- **Player-Facing Goal:** Reach the roof and receive a clear final time and victory.
- **Why This Session Happens Now:** The finite level and HUD provide the required trigger and end-state data.
- **Dependencies:** Sessions 01-13.
- **Current Relevant Files:** Scripts/ClimbLevel.gd; Scenes/Levels/ClimbLevel.tscn; Scripts/RunController.gd; Scripts/RunState.gd; Scripts/HUD.gd.
- **Nodes Involved:** Rooftop StaticBody2D, Goal Area2D/CollisionShape2D, Victory Control.
- **Scenes Involved:** New Scenes/UI/Victory.tscn; Scenes/Levels/ClimbLevel.tscn; Scenes/Levels/Run.tscn.
- **Scripts Involved:** Scripts/ClimbLevel.gd, Scripts/RunController.gd, new Scripts/Victory.gd.
- **New Nodes Expected:** Goal and Victory presentation.
- **New Scripts Expected:** Scripts/Victory.gd.
- **Existing Files Allowed To Change:** Scripts/ClimbLevel.gd, Scenes/Levels/ClimbLevel.tscn, Scripts/RunController.gd, Scripts/RunState.gd terminal method, and new Victory scene/script.
- **Systems That Must Not Change:** Fight rules, floor-loss, timer formatting, HUD values, other level content.
- **Required Behavior:** Rooftop goal is one-shot, disables Birds, stops timer, freezes Climb, displays final time and highest floor, and offers Retry/Title.
- **Inspector / Exported Parameters:** Goal floor association and Victory button labels are scene-visible.
- **Signal Connections:** Goal body_entered -> ClimbLevel.victory_requested -> RunController; Victory buttons -> restart/title methods.
- **Edge Cases:** Goal overlap cannot fire twice; fight/paused states cannot win; final time is captured before UI changes.
- **Acceptance Criteria:** Completing floor 50 stops timer once; roof can be reached without a mandatory double jump; no new Bird spawns.
- **Test Procedure:** Set a test spawn near floor 50, land on goal, inspect screen/time, and test both buttons.
- **Manual Godot Editor Verification:** Open goal/Victory scenes; adjust goal shape and text; run and reproduce.
- **Regression Tests:** Run to floor 49; confirm not victorious before overlap; ensure timer and Bird rules remain correct.
- **Evidence Required:** Goal tree/shape, final time screenshot, one-shot signal observation, changed paths.
- **Definition of Done:** Human review gate passes; Victory is visible, editable and terminal.
- **Next Session Unblocked:** Game Over Screen.

## Session 15 - Game Over Screen

- **Player-Facing Goal:** Understand the run ended after the ninth lost Life and choose Retry or Title.
- **Why This Session Happens Now:** Bird loss state already exists; this session supplies its terminal presentation.
- **Dependencies:** Sessions 01-14.
- **Current Relevant Files:** Scripts/RunState.gd; Scripts/RunController.gd; Scripts/HUD.gd; Bird outcome path.
- **Nodes Involved:** GameOver Control, final result labels, Retry/Title buttons.
- **Scenes Involved:** New Scenes/UI/GameOver.tscn; Scenes/Levels/Run.tscn.
- **Scripts Involved:** New Scripts/GameOver.gd; Scripts/RunController.gd.
- **New Nodes Expected:** GameOver panel and controls.
- **New Scripts Expected:** Scripts/GameOver.gd.
- **Existing Files Allowed To Change:** Scripts/RunState.gd terminal signal; Scripts/RunController.gd; new Scenes/UI/GameOver.tscn and Scripts/GameOver.gd.
- **Systems That Must Not Change:** Life deduction amount, Energy consequence, fight math, floor penalty, Victory behavior.
- **Required Behavior:** Exactly zero Lives after a lost Bird Fight stops timer and opens Game Over. Show final time, highest floor and Lives 0. Retry starts a fresh run; Title returns to menu.
- **Inspector / Exported Parameters:** Result labels and button text are editable in the scene.
- **Signal Connections:** RunState.game_over -> RunController terminal overlay; buttons connect to retry/title.
- **Edge Cases:** Energy fight loss never opens Game Over; multiple zero-Life signals cannot stack screens; Retry resets previous encounter.
- **Acceptance Criteria:** Zero Life never resumes Climb; retry resets nine Lives, 100 Energy, floor 1, timer 0; title route works.
- **Test Procedure:** Force Lives=1; lose Bird fight; inspect result; retry and verify defaults; repeat and choose Title.
- **Manual Godot Editor Verification:** Open Scenes/UI/GameOver.tscn; inspect controls/references, edit text, run and reproduce.
- **Regression Tests:** Bird defeat at Lives 2 to 1 does not end; Victory continues to display only on floor 50.
- **Evidence Required:** Before/after state, Game Over screen, fresh RunState screenshot and path diff.
- **Definition of Done:** Human review gate passes; terminal state is distinct and cannot return to a dead run.
- **Next Session Unblocked:** Audio and Feedback.

## Session 16 - Audio and Feedback

- **Player-Facing Goal:** Hear clear, distinct cues for jump, double jump, Bird warning, Strike, Brace, victory and loss.
- **Why This Session Happens Now:** Rules and screens are stable enough to assign cues that reinforce them.
- **Dependencies:** Sessions 01-15.
- **Current Relevant Files:** Audio/Songs/cat_song1.mp3; Audio/Songs/cat_song2.mp3; Scenes/Levels/Run.tscn; Scenes/Player/Player.tscn; Scenes/Gameplay/Bird.tscn; Scenes/UI/Fight.tscn; Scenes/UI/HUD.tscn; Scenes/UI/Victory.tscn; Scenes/UI/GameOver.tscn.
- **Nodes Involved:** Small AudioStreamPlayer/AudioStreamPlayer2D nodes under their behavior-owning scenes.
- **Scenes Involved:** Scenes/Levels/Run.tscn; Scenes/Player/Player.tscn; Scenes/Gameplay/Bird.tscn; Scenes/UI/Fight.tscn; Scenes/UI/HUD.tscn; Scenes/UI/Victory.tscn; Scenes/UI/GameOver.tscn.
- **Scripts Involved:** Scripts/Player.gd; Scripts/Bird.gd; Scripts/BirdSpawner.gd; Scripts/FightController.gd; Scripts/HUD.gd; Scripts/Victory.gd; Scripts/GameOver.gd; Scripts/RunController.gd only if a Run-owned music reference is needed.
- **New Nodes Expected:** AudioStreamPlayer nodes; no central audio service unless later proven necessary.
- **New Scripts Expected:** None.
- **Existing Files Allowed To Change:** The listed production scenes and owner scripts; Audio/Songs/cat_song1.mp3 and Audio/Songs/cat_song2.mp3 as read-only inputs; optional new project-owned files under Audio/SFX/ only if supplied/approved. Do not add an audio service or third-party audio dependency.
- **Systems That Must Not Change:** Movement timings, bird intervals, combat rules, Energy/Lives, timer.
- **Required Behavior:** Listen to both existing tracks and assign a suitable loop to Climb/Fight if they fit. Keep action feedback immediate and visibly clear. Use one-shot sound effects only where project-owned files are available; the current repository contains music tracks but no dedicated SFX, so do not block gameplay readability on missing effect assets.
- **Inspector / Exported Parameters:** Stream and volume are visible on player/hazard/fight audio nodes; avoid hard-coded global volume.
- **Signal Connections:** Reuse existing gameplay signals to trigger local sound; do not add an audio event bus.
- **Edge Cases:** Bird warning visual appears before spawn; pause does not restart or duplicate music; terminal transition stops or switches the current loop cleanly; no audio stream stalls scene.
- **Acceptance Criteria:** Existing music is Inspector-editable and clearly suited to its mode; visual action cues remain clear even without SFX; no cue claims an event that did not occur.
- **Test Procedure:** Play both existing tracks; run Climb/Fight/Victory/GameOver, pause/resume, adjust volume in Inspector and listen for transition or duplication errors.
- **Manual Godot Editor Verification:** Select each AudioStreamPlayer, replace stream with a test clip, tune volume and reproduce.
- **Regression Tests:** Audio nodes do not alter game state; Fight/Climb signals remain exactly once.
- **Evidence Required:** Audio event checklist, relevant scene screenshots, track/source notes and changed paths.
- **Definition of Done:** Human review gate passes; audio can be changed in Inspector and no new architecture is needed.
- **Next Session Unblocked:** Feel and Balance Polish.

## Session 17 - Movement, Readability, and Balance Polish

- **Player-Facing Goal:** Make the full run readable, fair, and responsive without adding new mechanics.
- **Why This Session Happens Now:** End-to-end play can reveal concrete tuning or feedback defects.
- **Dependencies:** Sessions 01-16.
- **Current Relevant Files:** Scripts/Player.gd; Scripts/ClimbingCamera.gd; Scripts/ClimbLevel.gd; Scenes/Levels/ClimbLevel.tscn; Scenes/Gameplay/Bird.tscn; Scenes/UI/Fight.tscn; Scenes/UI/HUD.tscn; existing AudioStreamPlayer nodes.
- **Nodes Involved:** Existing gameplay and UI nodes only.
- **Scenes Involved:** Existing production scenes only.
- **Scripts Involved:** Existing owners only.
- **New Nodes Expected:** None unless a specific playtest finding justifies a small visual/audio cue.
- **New Scripts Expected:** None.
- **Existing Files Allowed To Change:** Only the exact scene/script found defective during a reproducible playtest; report each change.
- **Systems That Must Not Change:** No new traversal type, combat action, enemy, energy rule, progression mode, or feature.
- **Required Behavior:** Fix only identified defects in jump/land readability, camera snapping, warning visibility, choice feedback, HUD hierarchy, or timing. Keep accepted design decisions unchanged.
- **Inspector / Exported Parameters:** Prefer tuning existing exports before adding new ones; document final values in 10_MASTER_DECISIONS.md.
- **Signal Connections:** No global signal redesign.
- **Edge Cases:** Run from fresh reset, fight-return, floor-1 respawn, floor-45 return, focus pause and low Energy.
- **Acceptance Criteria:** Target first clear 2-4 minutes is measured; every Bird telegraph has escape space; no forced double jump; both fights remain short.
- **Test Procedure:** Full runs by a developer unfamiliar with the code, note completion time and every confusing/unfair moment; retest targeted fixes.
- **Manual Godot Editor Verification:** Open each changed scene, inspect exact edited node/property, reproduce issue and fix, restore unrelated Inspector values.
- **Regression Tests:** Run all scenarios in 08_QA_AND_REGRESSION_PLAN.md.
- **Evidence Required:** Before/after clip or steps for each fix, updated decision values, time measurements, scoped diff.
- **Definition of Done:** Human review gate passes; polish solves observed problems and adds no hidden system.
- **Next Session Unblocked:** Final Integration QA.

## Session 18 - Final Integration QA and Release Readiness

- **Player-Facing Goal:** Complete a full run without regressions or unexplained blockers.
- **Why This Session Happens Now:** Every planned gameplay system and polish change is complete.
- **Dependencies:** Sessions 01-17 pass.
- **Current Relevant Files:** All production scenes/scripts and 08_QA_AND_REGRESSION_PLAN.md.
- **Nodes Involved:** Entire production tree.
- **Scenes Involved:** MainMenu, Run, ClimbLevel, Player, all traversal, Bird, Fight, HUD/Pause, Victory, GameOver.
- **Scripts Involved:** All production scripts; test harness scripts if approved.
- **New Nodes Expected:** None.
- **New Scripts Expected:** A small test harness only if QA reveals a repeatable case not otherwise testable; no new gameplay code.
- **Existing Files Allowed To Change:** Only bug-fix paths demonstrated by a failing test; preserve the user's preexisting dirty scenes and generated UID files.
- **Systems That Must Not Change:** No scope expansion, balance changes without recorded decision update, or architecture replacement.
- **Required Behavior:** Pass code/scene-load checks, manual Editor review, complete gameplay scenarios, timer, transitions, victory and Game Over. Fix failures before signoff.
- **Inspector / Exported Parameters:** Verify all accepted constants against 10_MASTER_DECISIONS.md and test one representative tuning export per system.
- **Signal Connections:** No duplicate, missing or orphaned production signal connections.
- **Edge Cases:** See the full regression matrix in 08_QA_AND_REGRESSION_PLAN.md, including all fight result, respawn, pause, and terminal paths.
- **Acceptance Criteria:** Every QA scenario passes; all production scenes open; no unexpected parser/runtime errors; complete run has clear evidence.
- **Test Procedure:** Follow every procedure in 08_QA_AND_REGRESSION_PLAN.md; perform one successful run, one zero-Life Game Over, and one fresh Retry.
- **Manual Godot Editor Verification:** Open each production scene, inspect node ownership/exports, change and restore a tuning value, run and reproduce at least one feature from every system.
- **Regression Tests:** All previous session gates; current worktree changes stay separate; inspect exact staged paths before commit.
- **Evidence Required:** Completed QA matrix, exact Godot version, clean scene-load/run diagnostics, successful run record, editor review screenshots, path-limited final diff.
- **Definition of Done:** Human review gate passes; all accepted systems are readable, editable and regression-safe; no important TODO or undocumented failure remains.
- **Next Session Unblocked:** Release candidate review; no new feature session is implied.

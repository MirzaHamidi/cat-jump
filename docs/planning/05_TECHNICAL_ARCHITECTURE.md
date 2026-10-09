# Human Must Never Know - Technical Architecture

## Architecture rule

Build this small game with normal Godot 4.7-era concepts: scenes, nodes, attached GDScript, signals, exported properties, CollisionShape2D, Area2D, Timer, AnimationPlayer, AudioStreamPlayer, and editor-authored scene instances. Keep important tuning visible in the Inspector. Do not build a custom framework, a universal manager, ECS, or generated level tree.

## Production tree

The following is a conceptual target tree; exact node names may change only if clarity improves.

    Scenes/UI/MainMenu.tscn (Node2D preserving the existing title composition)
        Title art (existing nodes)
        MenuUI (CanvasLayer)
            Control
                StartButton, QuitButton

    Scenes/Levels/Run.tscn (Node2D, RunController.gd)
        RunState (Node, RunState.gd)
        RunMusic (AudioStreamPlayer; selected existing project track)
        World (Node2D)
            ClimbLevel (instance of Scenes/Levels/ClimbLevel.tscn)
                Environment (Node2D)
                Traversal (Node2D)
                    Floor_001 ... Floor_050 (instances of Scenes/Gameplay/FloorTier.tscn; FloorTier.gd exports floor_number)
                        Traversal (Node2D with editor-placed reusable scenes)
                        RespawnAnchor (Marker2D child; position is Player root's safe standing position)
                Hazards (Node2D)
                    BirdSpawner (Node2D with Timer and Bird PackedScene)
                        LaneMarkers (Node2D)
                            Lane_01 ... Lane_04 (Marker2D, assigned in Inspector)
                        WarningCue (CanvasLayer/Control)
                Player (instance of Scenes/Player/Player.tscn, CharacterBody2D)
                Camera2D (ClimbingCamera.gd)
                RooftopGoal (Area2D)
        HUDLayer (CanvasLayer)
            HUD (Control)
        FightLayer (CanvasLayer)
            Fight (instance of Scenes/UI/Fight.tscn, Control; only during an encounter)
        OutcomeLayer (CanvasLayer)
            Victory or GameOver (Control, instanced at run end)
        PauseLayer (CanvasLayer)
            PauseMenu (Control; process while SceneTree is paused)

The player, camera, world and respawn anchors remain alive while Fight is displayed. No ClimbLevel reload is needed to return from combat.

## Ownership

| Node/script | Owns | Does not own |
|---|---|---|
| RunState | Energy, maximum, Lives, current/highest floor, elapsed run seconds; emits focused change/depletion signals. | Mode or encounter ownership, scene instancing, player movement, UI layout, combat turns. |
| RunController on Run.tscn | Climb/Fight/terminal mode, encounter reason and lock, Fight instancing, exactly-once result resolution, scene-level references, RunMusic start/stop. | Detailed movement, Bird motion, fight rules, HUD rendering. |
| Player | Horizontal movement, normal jump timers, one-use double-jump flag, pipe attachment, velocity and collision. | Lives, Energy totals, fights, global UI. |
| ClimbLevel | Finite authored content, player/camera, current landing/floor reporting, BirdSpawner, respawn application and victory request. | Fight turn logic, Lives ownership, menu screens. |
| BirdSpawner | Spawn cadence, warning, one live Bird, cooldown, stopping/clearing hazard on encounter. | Bird body movement, fight resolution. |
| Bird scene | Downward movement, contact Area2D, one-hit flag, hit/pass signal. | Lives, Energy, global mode. |
| Fight scene / FightController | Three Fight HP, six opponent HP, intent pattern, Scratch/Brace, one result signal. | Overworld Lives, Energy, respawn, run clock. |
| HUD | Displays RunState values and controls pause presentation. | Mutating gameplay values. |
| FloorTier scene / RespawnAnchor child | Floor number, editor-authored traversal instances, and exact safe respawn position for that tier. Anchor gets its floor identity from its parent. | Selecting its own consequences. |

## Interaction and signals

- Player calls a small RunState method to spend Energy; RunState emits energy_changed(current, maximum) and emits energy_depleted only on a transition to zero.
- RunController connects energy_depleted, ClimbLevel.bird_encounter_requested, and ClimbLevel.victory_requested. It validates mode/lock and defers start when needed to leave a physics callback safely.
- Player emits a local landing signal with the contacted collider; ClimbLevel walks that collider's parent chain to its owning FloorTier and updates RunState only after landing.
- Bird Area2D detects Player using collision layers/masks and emits once. BirdSpawner owns the Timer, four assigned lane markers, deterministic left-to-right lane cycle, warning, and selected scene. ClimbLevel turns the Bird hit into a single encounter request.
- Fight emits fight_finished(victory: bool) exactly once. RunController applies reason-specific state changes, asks ClimbLevel to resume or respawn, removes Fight, unlocks state, and returns to Climb.
- RunState emits focused lives_changed, floor_changed, and timer_changed signals. HUD listens; it formats values and does not calculate game rules.
- RooftopGoal reports one overlap to ClimbLevel; RunController moves to terminal Victory.
- No global signal bus. Direct parent/child references are appropriate where ownership is obvious.

## Fight transition and safety

ClimbLevel is set to PROCESS_MODE_DISABLED while FightLayer's Fight scene is active. Run.tscn itself is not paused, so RunState's timer and Fight actions continue. The pause menu uses SceneTree.paused separately. On victory, restore ClimbLevel without changing Player position, velocity, jump state, or Camera2D. On defeat, ClimbLevel selects the FloorTier exactly five floors below the last landing (clamped to 1), places the Player at its child RespawnAnchor, zeroes velocity and movement timers, resets the double-jump and pipe state, resets the camera follow high-water value, applies Bird grace/cooldown, then resumes processing.

Never hide state in a static variable or autoload. RunState is a regular node because its lifetime is exactly one run and it survives the Climb/Fight overlay changes. The next run creates a fresh Run.tscn.

## Scene and traversal architecture

- Player remains a scene with CharacterBody2D root, CollisionShape2D, Sprite2D, optional small feedback nodes, and Player.gd.
- Each traversal object is an ordinary reusable .tscn with its visual and actual collisions. Keep existing exact asset paths from the audit. StandardWindow is instanced directly in production; WindowRow remains only in core_climb_test. Each editor-authored FloorTier instance owns its floor_number, Traversal child, and RespawnAnchor child.
- Bird.tscn is a PackedScene instanced by BirdSpawner because runtime spawn is required.
- BirdSpawner exports its Bird PackedScene, lane-marker references, warning duration, warm-up, interval range, spawn height and bird_speed; it passes bird_speed into each spawned Bird instance, which owns its downward motion and contact flag. This keeps the requested speed control visible on BirdSpawner while movement remains with Bird. Lane selection is a deterministic left-to-right cycle.
- Fight, Victory, and GameOver are reusable PackedScenes at Scenes/UI/Fight.tscn, Scenes/UI/Victory.tscn, and Scenes/UI/GameOver.tscn, created only for their modes.
- Floor groups and their object instances are saved in ClimbLevel.tscn. The base game runs with those authored instances; no procedural generator is required.
- Add exported properties for movement, pipe climb speed, bird interval/speed/warning, and encounter timing where a designer needs to tune them. Keep maximum Energy, Lives, and floor-loss rules in the one RunState/decision source; do not duplicate those rules across nodes.

## Folders and naming

Preserve established paths: Scripts/Player.gd, Scripts/ClimbingCamera.gd, Scripts/BuildingScroller.gd, Scripts/WindowRow.gd, Scenes/Gameplay/StandardWindow.tscn, and Scenes/Assets/Environment/*.tscn. Canonical new scene paths are Scenes/UI/MainMenu.tscn, Scenes/Levels/Run.tscn, Scenes/Levels/ClimbLevel.tscn, Scenes/Player/Player.tscn, Scenes/Gameplay/FloorTier.tscn, Scenes/Gameplay/Bird.tscn, Scenes/UI/Fight.tscn, Scenes/UI/HUD.tscn, Scenes/UI/PauseMenu.tscn, Scenes/UI/Victory.tscn, and Scenes/UI/GameOver.tscn. RespawnAnchor is a Marker2D child inside each FloorTier, not a separate scene. Keep scripts in Scripts/ unless a focused subfolder substantially improves browsing. Canonical new scripts are Scripts/MainMenu.gd, Scripts/RunController.gd, Scripts/RunState.gd, Scripts/ClimbLevel.gd, Scripts/FloorTier.gd, Scripts/Bird.gd, Scripts/BirdSpawner.gd, Scripts/FightController.gd, Scripts/HUD.gd, Scripts/PauseMenu.gd, Scripts/Victory.gd, and Scripts/GameOver.gd. Use PascalCase for new scene/node names, snake_case for GDScript files and methods, and signal names describing past events (for example energy_depleted, body_entered, fight_finished).

## Autoload and Resource decisions

No Autoload is justified. Main menu can switch to Run.tscn; all persistence needed during a run stays inside that Run scene while modes overlay. There is no cross-run profile, save, or settings system in scope.

No custom Resource is required for two encounter reasons, fixed combat rules, or a hand-authored level. Use exported values on the node that owns the behavior. Add a Resource only if multiple data-heavy level variants later make it clearer than inspecting scene exports.

## Editor review requirement

Every new manager/system must have a visible owner node and concise attached script. After each Developer AI session, the user must be able to open Godot, open the affected scene, see and select the nodes, read their scripts, inspect exports, tweak values, run the scene, and reproduce the behavior. A hidden code-only success is incomplete.

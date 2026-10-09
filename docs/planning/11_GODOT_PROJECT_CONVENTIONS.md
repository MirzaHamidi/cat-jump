# Human Must Never Know - Godot Project Conventions

Practical conventions for future Developer AI work.

## General

- Use the project version recorded in project.godot and compatible Godot 4.x GDScript.
- Prefer a small clear solution a human can inspect over an abstract solution written for AI convenience.
- Inspect git status before editing. Do not discard, normalize, stage or commit unrelated user changes.
- Change only roadmap-allowed files. Run Editor/runtime verification only for the current session and report the exact result.
- Use the Inspector and scene editor as normal authoring tools, not as a last-mile display for code-created nodes.

## Nodes, scenes and ownership

- Reusable visible/interactable world objects belong in .tscn scenes with visible nodes and actual CollisionShape2D children.
- Use CharacterBody2D for the cat, StaticBody2D for stationary landings, and Area2D for non-solid detection.
- Name major node branches by concept: Environment, Traversal, Hazards, Player, Camera2D, UI.
- A script stays on the node that owns its behavior: Player movement on Player; Bird motion/collision on Bird; spawn cadence on BirdSpawner; Fight turn logic on Fight; presentation on HUD.
- FloorTier and its platform instances remain editor-visible. Do not build the whole 50-floor hierarchy with script.
- Runtime instancing is appropriate for a Bird or a temporary Fight/outcome scene when the game needs it. The instantiated object remains a PackedScene.
- PascalCase for scene/root/node names; snake_case for script files, variables, methods and signal names.

## GDScript and exported values

- Gameplay code uses GDScript. No C#, C++, GDExtension or external runtime framework.
- Use typed fields and short methods with names that express behavior. Avoid commented-out old code.
- Expose meaningful tuning values with @export and @export_range when a designer should tune them: jump speeds, Energy cost, climb speed, Bird timing/speed, camera framing and CollisionShape geometry.
- Give exported groups/categories useful names. Do not export internal counters that designers should not change.
- The node owning a behavior owns its value. Player owns double-jump cost/speed; RunState owns Energy totals/Lives; BirdSpawner owns interval and bird_speed, passes speed to each Bird instance, and Bird owns downward movement; FightController owns combat state.
- Keep scripts focused. There is no arbitrary line-count limit, but if a script mixes unrelated gameplay/UI responsibilities or becomes difficult to scan, split the responsibilities at their natural nodes. Do not create helper scripts that only support another needless abstraction.

## Signals, references and groups

- Prefer a direct reference when the parent visibly owns both nodes and a signal when a child reports a local event.
- Keep signals local to scene ownership; no global event bus.
- Signal names describe what happened, for example energy_depleted, bird_hit, fight_finished, floor_changed.
- Use editor signal connections when the relationship is fixed; connect in GDScript when repeated scene instances or runtime-created PackedScenes require it.
- Use groups only for clear multi-node queries such as all hazards or all traversal surfaces. Do not use groups as a service locator.

## Autoloads, Resources and managers

- Do not add an Autoload for this game. RunState belongs under Run.tscn and survives Fight overlays.
- Add an Autoload later only if a concrete requirement needs to survive replacement of the Run root or be globally accessed. Keep it small and document its lifetime.
- Do not add a custom Resource for a handful of constants. Export values on the owning node. A Resource is acceptable if many data-heavy level/encounter variants become clearer as reusable data than as scenes/exports.
- RunController coordinates mode and scene overlays only. It does not implement Player physics, Bird movement, combat math, or HUD rendering.

## Input, collisions and test scenes

- Use named InputMap actions rather than raw keycodes in gameplay scripts.
- Existing move_left, move_right and jump actions remain. Add move_up for PipeClimb, fight_scratch/fight_brace for combat, and pause for Escape only in their roadmap sessions. Do not use raw keycodes in gameplay scripts.
- Keep collision geometry visible in scenes and use collision debug visualization for route/hazard QA.
- Preserve core_climb_test.tscn as the mechanics test. Preserve apartment_grid_test.tscn and asset_showcase.tscn as authoring/showcase references.
- Put additional automated/smoke fixtures in a clearly named test folder or scene; never hide test-only controls in production UI.
- Restore temporary test exports/values before committing.

## Comments and review

- Comment why a non-obvious rule exists, not what the next line says.
- Document unusual inspector configuration near the owning scene/script. Prefer editor self-description and configuration warnings over an invisible convention.
- Inspect the tree after saving; confirm scene instances still point to the intended PackedScene and external references.
- A feature is incomplete until the human can select the node, inspect the script/exports, tune it, run the scene and reproduce its behavior.

# Human Must Never Know - Current Repository Audit

Audit basis: working tree inspected on 2026-10-09. This document describes both committed history and existing local edits. No source or scene was changed for this planning package.

## Repository state

- Repository: https://github.com/MirzaHamidi/cat-jump
- Snapshot at audit start: branch `main` at `1d093c6f544107dfdb5a536fa9aa30fe5cd152a3`, then also `origin/main`. During this planning session `origin/main` advanced with four early planning documents. Those commits were merged; the early drafts are retained and labeled by authority/supersession notes, and the current 12-document package in `docs/planning/` resolves the design and replaces the earlier roadmap.
- Project settings: project.godot config version 5, features include Godot 4.7 and Mobile, viewport 1280x720, canvas-items stretch. The configured main scene UID resolves to Scenes/Levels/game.tscn.
- Existing InputMap controls use A/D for move_left/move_right and Space for jump. The starting project has no pipe, Fight, or pause input actions.
- The title menu is Scenes/Levels/main_menu.tscn, a visual title composition with cat art and title text. It currently has no Start button or script.
- The latest committed climbing foundation is Scenes/Levels/core_climb_test.tscn with Scripts/Player.gd, Scripts/ClimbingCamera.gd, Scripts/BuildingScroller.gd, Scripts/WindowRow.gd, Scenes/Gameplay/WindowRow.tscn, and Scenes/Gameplay/StandardWindow.tscn.
- Tracked assets include Assets/cat.png, two MP3s under Audio/Songs/, three font files under Assets/UI/Fonts/, the CRT shader/script, and vector/polygon placeholder scenes.

## Existing local edits to preserve

At audit time the user worktree contained these edits:

- Modified: Scenes/Levels/apartment_grid_test.tscn, Scenes/Levels/asset_showcase.tscn, Scenes/Levels/core_climb_test.tscn, and Scenes/Levels/game.tscn.
- Untracked: Scenes/Levels/chunk_test.tscn, Scripts/BuildingScroller.gd.uid, and Scripts/WindowRow.gd.uid.

The modified scenes contain editor-saved unique IDs, transform/inspector changes, and content changes. They belong to the user and must not be reset, reformatted, staged, or included in a planning-only commit.

The untracked Scenes/Levels/chunk_test.tscn still references Scenes/Levels/Chunks/Test/Chunk_01_Zigzag.tscn through Chunk_05_Vertical.tscn. Those referenced chunk files are absent from the current repository after the revert described below. The file is therefore a local incomplete test artifact, not a production base. Leave it untouched until the user decides whether to restore or remove it.

## Scripts and scene audit

| Path | What it currently does | Production disposition |
|---|---|---|
| Scripts/Player.gd | CharacterBody2D movement. Exports speed/acceleration/deceleration, jump velocity, coyote and buffer windows, jump cut, rising/falling gravity, and fall cap. | Preserve its movement behavior and readable script. Add the one-use double jump in a later dedicated session. |
| Scripts/ClimbingCamera.gd | Camera follows the player upward with smoothing and follows downward only after a threshold. | Reuse; add an explicit snap method for a fight-loss respawn. |
| Scripts/BuildingScroller.gd | Creates a fixed pool of WindowRow scenes, updates floor display after landing, scrolls camera, recycles rows. It exports key test settings and requires Player, Camera2D, and Label references. | Keep for the current scrolling mechanics test only. Do not make runtime row recycling the finite game's production level system. |
| Scripts/WindowRow.gd | Stores an exported floor number on a row. | Keep as a helper for the existing test scene only. |
| Scripts/crt.gd and Assets/Effects/Shaders/CRT.gdshader | Mouse forwarding and CRT presentation experiment. | Optional presentation experiment, not required by the production climb architecture. |
| Scenes/Gameplay/StandardWindow.tscn | Reusable StaticBody2D with visual window and 240-pixel-wide one-way ledge collision. | Primary standard-window placeholder for the finite production layout. |
| Scenes/Gameplay/WindowRow.tscn | Four StandardWindow instances at x=220, 500, 780, and 1060. | Retain for core scrolling test, not the hand-authored level. |
| Scenes/Levels/core_climb_test.tscn | Start ground, player, camera, floor CanvasLayer/Label, BuildingScroller, and Rows. The script currently populates/recycles rows at run time. | Best movement/camera harness; retain as test scene. Production will use a separate finite ClimbLevel scene. |
| Scenes/Levels/game.tscn | Configured main scene. In the committed version it was a hand-built platform test; the current working version has been edited to show window samples and has no committed old layout. | Retire as the production scene; retain as an archival sandbox until production scenes are stable. Do not overwrite the user's current edit. |
| Scenes/Levels/Apartment/NormalWindow.tscn and Scenes/Levels/apartment_grid_test.tscn | Larger one-way window ledge and hand-positioned 3 columns x 6 rows test layout. | Keep the scene as a manual placement reference/test. Avoid maintaining a second production window/floor scheme. |
| Scenes/Assets/Environment/BuildingFacadePiece.tscn | Polygon/Line2D facade visual. | Reuse as decorative placeholder if useful. |
| Scenes/Assets/Environment/ACUnit.tscn | StaticBody2D with a 144-wide one-way stand surface. | Reuse as a narrow landing/route choice. |
| Scenes/Assets/Environment/FireEscapePlatform.tscn | StaticBody2D with a 210-wide one-way landing. | Reuse as a broad rest/landing surface. |
| Scenes/Assets/Environment/FireEscapeStair.tscn | Stair visuals and Area2D interaction volume; no walkable steps currently. | Reuse its visual; add explicit step collisions in a dedicated implementation session before it is used as traversal. |
| Scenes/Assets/Environment/PipeClimb.tscn | Pipe visuals and Area2D volume; no behavior currently. | Reuse visuals and ClimbArea; add the small climb interaction later. |
| Scenes/Assets/Environment/Balcony.tscn | StaticBody2D balcony with 200-wide one-way landing. | Reuse as broad landmark/rest surface. |
| Scenes/Assets/Windows/WindowForbidden.tscn, WindowHater.tscn, WindowLover.tscn | Characterful polygon window variants, each with one-way sill. | Keep in asset showcase/prototype. They do not become hazards, characters, or gameplay rules in this scope. |
| Scenes/Levels/asset_showcase.tscn | Manually placed asset display with Player and sample objects. | Keep as an editor asset showcase/test, not as a production level. |
| Scenes/Levels/main_menu.tscn | Cat/title visual with supplied font. | Preserve presentation; add menu controls in its own session. |

## Prototype history

- 12655d5 initialized the project.
- 6ad6da6 added the arcade movement test room and ClimbingCamera.
- 84751c3 tracked the camera script UID.
- 740d72c added a manually composed apartment-chunk prototype; f41b0d2 reverted that prototype and removed its chunk scenes/script. Do not revive that architecture.
- b4bd601 added the regular 3x6 apartment grid and NormalWindow; 4db96c5 made those ledges one-way.
- af96e76 added the polygon placeholder asset kit and showcase.
- 1d093c6 added the four-column endless scrolling climb.

Prior verified history recorded in the project memory says the 20-row pool remains 20 rows / 80 windows while climbing, floor display follows the highest landed row, and the player/camera controller was smoke-tested there. That history is useful for identifying what the harness tests; it does not validate the current dirty working tree or the new finite game.

## Production foundation decision

Keep the current responsive Player and camera as the movement baseline, the StandardWindow as the common platform, and the existing Environment scenes as reusable placeholders. Make a new finite, editor-authored production level and a small run root. The four-column row recycler remains an isolated test harness. The older generic platform scene, NormalWindow grid, window-character variants, and reverted chunk approach do not become competing production architectures.

The production level will be authored by placing scene instances into clearly named floor groups. It will not require an endless row pool, a chunk generator, or a hidden hierarchy created by GDScript. Runtime instancing remains appropriate for the Bird PackedScene and temporary Fight/UI scenes.

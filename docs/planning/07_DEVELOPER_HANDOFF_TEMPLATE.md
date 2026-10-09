# Human Must Never Know - Developer AI Handoff Template

Copy this document for one future implementation session. Fill every bracketed field from 06_DEVELOPMENT_ROADMAP.md and the authoritative design documents. Give the Developer AI only one numbered session at a time.

## Handoff

**Implement Development Session [NN]: [Exact System Name]**

### Goal and authority

- Player-facing goal: [from the session packet]
- Reason this is the next session: [from the dependency sequence]
- Read first: 00_GAME_VISION_AND_SCOPE.md, 01_CURRENT_REPOSITORY_AUDIT.md, 02_GAMEPLAY_SYSTEM_SPEC.md, 03_TURN_BASED_COMBAT_SPEC.md, 04_LEVEL_DESIGN_AND_PROGRESSION.md, 05_TECHNICAL_ARCHITECTURE.md, 06_DEVELOPMENT_ROADMAP.md, 08_QA_AND_REGRESSION_PLAN.md, and 10_MASTER_DECISIONS.md.
- This session's exact required behavior: [copy the roadmap behavior].
- The Master Decisions document is authoritative for numeric constants. Do not redesign rules or invent missing combat/level behavior.

### Scope

- Dependencies already complete: [session numbers]
- Current relevant files: [paths]
- Nodes involved: [names and owning scene]
- Scenes involved: [paths]
- Scripts involved: [paths]
- New nodes expected: [names/types]
- New scripts expected: [paths]
- Existing files allowed to change: [exact list]
- Systems that must not change: [exact list]

Do not modify or stage unrelated work. At task start, inspect git status. Treat all existing dirty or untracked files as user-owned unless specifically in this session's allowed-path list. Never reset the worktree or broadly stage changes.

### Godot development requirements

Implement this system using ordinary Godot 4.x development practices. Use Nodes, Scenes, GDScript, appropriate child hierarchies, signals where they clarify ownership, exported tuning values in the Inspector, reusable .tscn scenes, and actual CollisionShape2D/Area2D/CharacterBody2D nodes where they fit.

- Keep the Scene dock clear enough for a human to locate each system.
- Let a designer select the object and tune important values in the Inspector.
- Let a human manually move, duplicate, inspect and replace level instances.
- Keep scripts attached to the node that owns their behavior.
- Use direct references when ownership is obvious; use local signals when they reduce coupling.
- Runtime spawning is allowed only where specified, and the spawned object remains a proper PackedScene.

Do not introduce C#, C++, GDExtension, an external runtime framework, custom engine, homemade ECS, giant manager, large inheritance tree, general-purpose factory, service locator, global event bus, reflection framework, or dynamically generated level hierarchy. Do not put the whole game in Player.gd or RunController.gd. Do not hide editable content or important gameplay values in generated code.

### Inspector, signals and edge cases

- Inspector/exported values: [names, initial values and owner]
- Required signal connections: [signal, sender and receiver]
- Edge cases: [from roadmap packet]
- Explicitly forbidden changes: [list]

### Verification

- Acceptance criteria: [copy roadmap criteria]
- Test procedure: [copy roadmap procedure]
- Manual Godot Editor verification: open the named scene, inspect the created nodes/scripts/exports, change one relevant value, run the scene, and reproduce the feature.
- Regression tests: [copy the session's named checks]
- Evidence required: [screenshots/log/capture/state values/diff]
- Definition of Done: The feature is functional, Godot-native, manually editable, tested, documented, regression-safe, visible in the correct scene, configurable where appropriate, and has no important TODO.
- Next session unblocked: [exact roadmap item]

### Required human review

After the session the user must be able to open Godot; open the relevant scene; see and understand nodes; select them; inspect attached scripts and exported variables; manually tweak a relevant value; run the scene; and reproduce the system. A feature that only works because of hidden or incomprehensible AI-created architecture is incomplete.

If the acceptance criteria fail, repair the current session and rerun regression. Do not proceed to the next session. Report changed paths, exact tests and manual steps, results, evidence, and any remaining limitation.

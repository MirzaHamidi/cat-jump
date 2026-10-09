# Human Must Never Know - Reference and Research Notes

This planning pass used the current Godot stable documentation and the design references requested in the brief. These are short summaries in our own words, not reproductions of books.

## Godot technical references

| Source | Principle used | Decision influenced |
|---|---|---|
| [CharacterBody2D class reference](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html) and [Physics introduction](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html) | CharacterBody2D is moved by script and supports floor/wall-aware move_and_slide behavior; StaticBody2D is suitable for stationary environmental landings. | Keep the current player controller as CharacterBody2D and normal ledges as StaticBody2D; do not replace it with a physics-engine framework. |
| [Area2D class reference](https://docs.godotengine.org/en/stable/classes/class_area2d.html) and [Using Area2D](https://docs.godotengine.org/en/stable/tutorials/physics/using_area_2d.html) | Areas detect overlaps without serving as standable collision. Their layer/mask and body_entered signals must agree. | Bird hit, Pipe ClimbArea, and rooftop goal use explicit Area2D nodes; Bird and pipe Area2Ds are not platforms. |
| [Using signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) | Nodes can announce local events and an owner can respond. | Use focused signals such as energy_depleted and fight_finished, not an event bus. |
| [PackedScene reference](https://docs.godotengine.org/en/stable/classes/class_packedscene.html) | A PackedScene serializes a node hierarchy and can be instantiated as a normal scene. | Reusable traversal objects, Bird, Fight, and end screens stay real .tscn files. |
| [Timer class reference](https://docs.godotengine.org/en/stable/classes/class_timer.html) | Timer provides a scene-visible countdown with wait time, one-shot and start/stop behavior. | BirdSpawner owns an inspectable Timer; spawn cadence and warning intervals remain tunable in the Editor. |
| [AnimationPlayer class reference](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html) | AnimationPlayer provides named, editor-authored timelines for UI and object feedback. | Use short authored feedback when timing/sequence matters; do not encode a generic animation framework. |
| [Resource class reference](https://docs.godotengine.org/en/stable/classes/class_resource.html) | Resources are reusable data containers that can be saved independently from scene nodes. | Do not add custom Resources for a small fixed set of rules; reconsider only for repeated data-heavy variants. |
| [CollisionObject2D class reference](https://docs.godotengine.org/en/stable/classes/class_collisionobject2d.html) | Physics collision layers and masks define which objects detect or block each other. | Keep platforms on the solid world layer and triggers on a clear interaction layer, and verify masks per scene. |
| [GDScript exported properties](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html) | Exported values are serialized with scenes and editable in the Inspector. | Put jump, Bird, and pipe tuning on the node that owns that behavior. |
| [Scene organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html) | Scenes work best with focused responsibilities; use parent-owned references/signals and a scene tree organized by ownership. | Run, ClimbLevel, Player, BirdSpawner, Fight, and HUD each have a visible owner. |
| [Autoloads versus regular nodes](https://docs.godotengine.org/en/stable/tutorials/best_practices/autoloads_versus_regular_nodes.html) and [Autoload documentation](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) | Autoloads fit data that truly must be globally accessible and survive scene changes. | No Autoload: RunState lives inside Run.tscn, which remains alive over a Fight overlay. |
| [Changing scenes manually](https://docs.godotengine.org/en/stable/tutorials/scripting/change_scenes_manually.html) | SceneTree scene changes replace the active scene; a persistent parent can own sub-scenes. | Menu starts Run; in-run Fight is an overlay so RunState and Player remain alive. |

Godot documentation links use the stable channel. The current project declares feature version 4.7; Developer AI must confirm compatibility with the installed editor when implementation begins.

## Game design and systems references

| Source | Principle summarized | Decision influenced |
|---|---|---|
| Steve Swink, [Game Feel: A Game Designer's Guide to Virtual Sensation](https://www.routledge.com/Game-Feel-A-Game-Designers-Guide-to-Virtual-Sensation/Swink/p/book/9780429178566) | Moment-to-moment control is a core part of perceived quality; movement, cues and timing work together. | Preserve responsive controller qualities and add concise feedback when double jumping, landing, warning, blocking and taking damage. |
| Jesse Schell, [The Art of Game Design: A Book of Lenses](https://schellgames.com/art-of-game-design/) | Revisit the design through different player-experience questions, including motivation and challenge. | Check whether the next action is understandable, the risk is legible, and every feature supports the cat-climb fantasy. |
| Ian Schreiber and Brenda Romero, [Game Balance](https://www.routledge.com/link/link/p/book/9781032034003) | Balance requires fairness and challenge together; numerical assumptions need iteration and observation. | Keep Bird lanes telegraphed, provide an Energy-free route, cap combat to deterministic values, and validate timing in full runs. |
| Michael Sellers, [Advanced Game Design: A Systems Approach](https://www.pearson.com/en-us/subject-catalog/p/advanced-game-design-a-systems-approach/P200000009594) | A game's parts interact as loops; make the consequence and feedback of each interaction visible. | Explicitly close Energy-zero and Fight-return loops; keep Overworld Lives, Fight HP, timer, Energy and floor penalty distinct. |
| Christopher W. Totten, [An Architectural Approach to Level Design, Second Edition](https://www.routledge.com/Architectural-Approach-to-Level-Design-Second-edition/Totten/p/book/9781351116305) | Spatial composition, visibility, whiteboxing and pacing should support how players navigate and learn. | Hand-author floor groups, teach then combine traversal types, keep visible safe landings, and make the roof a readable finish. |
| Robin Hunicke, Marc LeBlanc and Robert Zubek, [MDA: A Formal Approach to Game Design and Game Research](https://aaai.org/papers/ws04-04-001-mda-a-formal-approach-to-game-design-and-game-research/) | Mechanics create dynamics that in turn shape the player's experience; analyze both implementation and outcome. | Mechanics (jump, Energy, warning) are specified alongside the intended play (route choice, anticipation, short interruption). |
| Robert Nystrom, [Game Programming Patterns](https://gameprogrammingpatterns.com/contents.html), especially [Observer](https://gameprogrammingpatterns.com/observer.html) and [State](https://gameprogrammingpatterns.com/state.html) | Observer/state patterns can clarify event response and mode-specific rules, but their value depends on actual complexity. | Use Godot signals and a small RunController mode enum; reject a custom state-machine framework and global event queue. |

## Applied principles

- MDA: Start from the player experience (nimble, tense, readable, brief interruption), then define mechanics and inspect their interaction loops. A mechanic is not justified only because it is easy to code.
- Game feel: Keep the existing jump features; tune from live movement, not from theory alone. Pair important actions with small visual and audio feedback; do not let effects delay control.
- Game balance: The fixed 100/25 Energy relationship and deterministic fight values are initial design decisions. Measure successful runs and failure causes before altering them. Random timing is confined to Bird arrival interval, while its path is announced.
- Level design: A 50-tier hand-authored route uses progressive introduction and combination. Layouts should be whiteboxed and tested with the actual controller; editor-manual placement is intentional.
- Systems thinking: Energy reaching zero starts one Fight; outcomes then restore or safely rearm Energy. Bird collisions and Fight HP are separated from Lives; every feedback loop has a defined terminal state.

## Approaches rejected

- Repeated runtime floor generation: rejected because the game is finite and the user wants manual level editing.
- Restoring the reverted chunk/generator architecture: rejected because the latest committed prototype is the row recycler, and neither runtime generation nor chunk generation is required.
- Autoload RunState: rejected because Run.tscn survives Climb/Fight mode overlays and can own all values for one run.
- Global event bus or service locator: rejected because RunController and scene-parent signals can express the small number of links.
- A generalized combat data/resource framework: rejected because there are two reasons using one fixed opponent rule set.
- Giant Player or RunController script: rejected because behavior belongs to Player, Bird, BirdSpawner, Fight, HUD and the run root.
- Random untelegraphed Birds or damage: rejected because they would turn a collision into an unavoidable penalty.
- Added RPG content: rejected because depth should come from traversal, Energy, hazards, time and consequences.

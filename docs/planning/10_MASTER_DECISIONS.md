# Human Must Never Know - Master Decisions

Status: authoritative numeric/rule table for the planning package. When a more detailed specification and a value here conflict, this table controls the value; the associated system specification controls the implementation meaning. Values marked **initial target** require the stated playtest gate, not design reinvention.

| ID | Decision | Rule | Reason | Status |
|---|---|---|---|---|
| D-01 | Working title | Human Must Never Know | User supplied title; repo is still named cat-jump. | Locked |
| D-02 | Engine and language | Godot 4.7 project; GDScript; ordinary 2D Nodes/Scenes | Matches repository and human editing requirement. | Locked |
| D-03 | Production level architecture | One finite manually authored ClimbLevel with 50 instances of the reusable FloorTier scene | Directly inspectable, duplicate/movable content; no runtime generation dependency. | Locked |
| D-04 | Prototype foundation | Preserve Player.gd/ClimbingCamera.gd; core_climb_test remains harness; game.tscn is not production | Avoid competing architectures and protect existing proven behavior. | Locked |
| D-05 | Autoload | None | RunState remains inside Run scene and survives Fight overlays. | Locked |
| D-06 | Main gameplay layout | Four-column facade reference x=220,500,780,1060; initial vertical tier pitch 100 px | Reuses current test geometry; each placement still requires real jump testing. | Initial target |
| D-07 | Normal movement | 340 max horizontal speed; accel/decel 2400/3000 ground and 1650/1000 air; jump -610; coyote/buffer 0.12s; cut 0.45; rise/fall gravity 1450/2300; fall cap 1050 | Existing Player.gd baseline, preserving all current good movement behavior. | Baseline; tune only from evidence |
| D-08 | Normal jump | Free; grounded or existing coyote window; buffered ground jump supported | Energy is reserved for optional second jump. | Locked |
| D-09 | Energy | Maximum/start 100; no passive refill or pickups | Resource applies pressure to double-jump choices. | Locked |
| D-10 | Double jump | One per airborne sequence after a normal jump; velocity -540 px/s; cost 25 Energy; one new button press; insufficient Energy refuses without spend | An optional recovery/shortcut that cannot become mandatory on the safe route. Cost/velocity are on Player exports; RunState owns total. | Initial target |
| D-11 | Energy depletion | One Energy fight at exactly zero caused by a successful double-jump spend; do not trigger on refused action | Prevents ambiguous/duplicate encounter starts. | Locked |
| D-12 | Energy fight victory | Restore Energy to 100; preserve player position/velocity/camera | Reward closes the Energy loop. | Locked |
| D-13 | Energy fight defeat | No Overworld Life lost; Energy becomes 50; move to exactly five floors below last safe landing (clamp to floor 1); clear motion/jump/pipe state; snap camera; 1.0s Bird grace | Nonzero Energy prevents immediate repeat; retreat has a deterministic cost. | Locked |
| D-14 | Overworld Lives | Start with 9; only lost Bird fight removes exactly 1; zero ends run | Kept separate from Fight HP and Energy. | Locked |
| D-15 | Fight HP | 3 at start of every Fight; resets for each encounter; never touches Lives | Short encounter-local health. | Locked |
| D-16 | Combat enemy/action values | Opponent 6 HP; Strike deals 1; Strike/Recover alternates starting with Strike on turn 1; Scratch deals 1; Brace blocks current Strike and deals no damage; Brace disabled on Recover | Deterministic fight requiring one visible defensive choice; usually 7 player actions, no more than 12 when bracing every Strike. | Locked |
| D-17 | Fight resolution | Scratch kills before retaliation; fight result emits once; same combat rules for Energy and Bird reasons | One reusable short encounter, no RPG layer. | Locked |
| D-18 | Bird activation | No Bird before floor 16. First landing on floor 16 starts a 25-second Climb-Mode warm-up. | Teach movement and optional Energy first. | Locked |
| D-19 | Bird timing/movement | One Bird at a time; deterministic left-to-right cycle starting at Lane_01 across four Inspector-assigned lanes; 1.5-second warning before each spawn; spawn 80 px above active camera; fall 600 px/s set on BirdSpawner; 35-45 seconds between warnings after the warm-up or an encounter return | Frequent enough for a few late-run decisions, with time to dodge and no hidden lane randomness. | Initial target |
| D-20 | Bird consequences | Dodge is free; Bird Fight win no Life/Energy cost; Bird Fight loss loses 1 Life and shared five-floor penalty; Energy unchanged | Avoiding danger saves time; defeat outcome stays explicit. | Locked |
| D-21 | Bird one-shot/grace | Bird local hit flag plus RunController mode lock; 1.0s contact grace after respawn; cancel active warning/Bird and schedule a fresh 35-45s cooldown on encounter return; stop scheduling at floor 49 | Prevent duplicate contact and repeated post-respawn hits. | Locked |
| D-22 | Run length/floors | 50 numbered tiers; floor 1 is the broad safe starting platform; first upward landing is floor 2; floor 50 is roof goal; the bottom platform catches missed jumps without another loss rule | Finite arcade climb matching initial planning target. | Locked |
| D-23 | Floor tracking | Update current floor on landing in a FloorTier; highest floor never decreases; defeat target based on last landed floor | Stable progress independent from midair position. | Locked |
| D-24 | Respawn anchors | One editor-authored Marker2D inside each FloorTier; marker position is the Player root's safe standing position and floor identity comes from its parent; target max(1,last_landed_floor-5) | Exact, safe, human-inspectable location without duplicated floor metadata. | Locked |
| D-25 | Pipe | While in ClimbArea, hold Up to climb at 160 px/s; no gravity/Energy cost; horizontal input or jump exits; does not refresh double jump | A slower alternate vertical route using existing pipe placeholder. | Initial target |
| D-26 | Other traversal | StandardWindow 240 px one-way; AC 144 px one-way; FireEscapePlatform 210 px one-way; Balcony 200 px one-way; FireEscapeStair consists of visible one-way step bodies | Each object provides a legible landing/route purpose. | Preserve scene widths; test in game |
| D-27 | Timer | Starts at Run launch; counts Climb, Fight and transition time; stops at Victory/Game Over; pauses with SceneTree pause/focus-loss pause | Fighting costs time; pausing is respected. | Locked |
| D-28 | Timer display | mm:ss.t; elapsed float stored in RunState; no best-time save | Clear run-time summary without a profile system. | Locked |
| D-29 | Completion time | First successful run target 2-4 min; practiced clean target about 90-150 sec | Start with 50 short tiers; measure before balancing further. | Initial target |
| D-30 | Collision convention | World/player solids on layer 1; Area2D interactions on layer 2 with Player layer 1 in mask; verify per scene | Simple inspectable separation for platforms vs triggers. | Initial convention |
| D-31 | HUD | Display Energy/current max, 9 Lives, current/highest floor, mm:ss.t; Fight scene separately shows 3 Fight HP | Makes next action/resource visible without mixing systems. | Locked |
| D-32 | Victory | One rooftop Area2D overlap at floor 50; stop timer and spawner; show summary and Retry/Title | Finite success condition. | Locked |
| D-33 | Game Over | Only when a lost Bird Fight reduces Lives to 0; stop timer; show summary and Retry/Title | Energy setbacks are recoverable. | Locked |
| D-34 | Visual scope | Placeholder SVG/Polygon2D/ColorRect/Line2D until systems/layout pass; no final art production in this plan | Communicate collision/readability before asset scope. | Locked |
| D-35 | Source changes | Production work proceeds by roadmap session; existing dirty scenes/UIDs preserved and path-limited | Protect user's local work. | Locked |
| D-36 | Fight presentation and controls | Energy opponent is named Exhaustion and uses an abstract shadow/energy silhouette; Bird Fight uses the colliding Bird; both share rules. `fight_scratch` maps to Z; `fight_brace` maps to X; buttons remain clickable. | One readable reusable Fight interface without a new enemy roster. | Locked |
| D-37 | Primary controls | Keyboard and mouse; preserve A/D for left/right and Space for jump; add W for pipe climb, Z/X for Fight, Escape for pause; no touch controls in the initial scope | Reuse the current InputMap and give each mode consistent visible controls. | Locked |
| D-38 | Canonical story premise | The cat lives with its human on the top floor of a 1000-floor plaza. The human leaves for work after telling the cat not to cause trouble. The cat secretly leaves, spends the day out, then notices sunset and realizes the human will soon return. With no safe route home, the cat climbs the plaza exterior and windows trying to reach home before the human and keep the disobedience secret. The 50 gameplay tiers are a production abstraction and do not redefine the 1000-floor fiction. | Locks the narrative motivation and meaning of the title without adding extra gameplay systems. | Locked |

## Playtest change control

Baseline D-07 and initial-target values D-06, D-10, D-19, D-25, D-26 and D-29 may change only after a reproducible test records the observed reachability/readability/timing and the revised reason. All other values are locked unless the user changes scope. No USER DECISION REQUIRED item is open for this plan.

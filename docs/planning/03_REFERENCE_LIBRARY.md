# CatJump — Game Manager Reference Library

This file gives the Game Manager a curated starting library for planning, architecture, feel, balancing, level design, and QA.

The manager should use legitimate public documentation, previews, publisher pages, papers, and legally accessible material. Do not copy copyrighted book text into project docs. Summarize principles and cite the source used.

---

# 1. Godot 4.7 — Primary Technical Source

## Godot 4.7 Documentation
https://docs.godotengine.org/en/4.7/

Use as the first source for engine behavior. The project currently targets Godot 4.7, so avoid casually copying patterns from older Godot 3 tutorials.

Research topics:
- scene ownership
- autoload / persistent state when justified
- CharacterBody2D
- collision layers/masks
- one-way platforms
- signals
- Area2D
- timers
- resources/custom resources
- scene changing
- animation and UI when relevant

## CharacterBody2D movement
https://docs.godotengine.org/en/4.7/tutorials/physics/using_character_body_2d.html

Relevant to:
- existing movement code
- `move_and_slide()`
- collision response
- jump/fall behavior
- avoiding direct position manipulation for normal character physics

Manager research question:
> Does the proposed movement/floor-penalty implementation respect CharacterBody2D physics ownership, or is it creating fragile teleport/collision behavior?

## Area2D
https://docs.godotengine.org/en/4.7/classes/class_area2d.html

Relevant to:
- bird contact
- trigger volumes
- top-of-building victory trigger
- safe event detection without forcing physical collision response

## Signals
https://docs.godotengine.org/en/4.7/getting_started/step_by_step/signals.html

Relevant to:
- Energy zero event
- bird collision encounter request
- combat resolution
- HUD updates
- reducing direct dependencies between unrelated systems

Manager research question:
> Can this event be expressed as a signal/event contract instead of making one unrelated node directly control another?

## Resources
https://docs.godotengine.org/en/4.7/tutorials/scripting/resources.html

Relevant to:
- encounter definitions
- authored floor/route data
- tuning parameters
- reusable data separated from behavior

## SceneTreeTimer
https://docs.godotengine.org/en/4.7/classes/class_scenetreetimer.html

Relevant to:
- bird telegraph windows
- short delays
- encounter transitions
- temporary control lockouts

Use carefully. Gameplay-critical timers must have documented pause/scene-change semantics.

---

# 2. Software Architecture / Game Code

## Game Programming Patterns — Robert Nystrom
https://gameprogrammingpatterns.com/

A free online game-programming architecture reference.

Priority patterns for this project:

### State
Use when reasoning about:
- Climb Mode vs Fight Mode
- combat turns
- player airborne/grounded/double-jump state if complexity justifies it

### Observer
Use when reasoning about:
- Energy changed
- lives changed
- encounter requested
- combat ended
- HUD reaction without hard coupling

### Event Queue
Consider only if synchronous signals become insufficient. Do not add a queue merely because the pattern exists.

### Object Pool
Relevant to:
- repeated floor/window rows
- repeated bird hazards

The repository already contains a row-pooling prototype. The manager should evaluate whether it helps the finite authored version or creates unnecessary complexity.

### Update Method / Game Loop
Useful for understanding per-frame ownership and avoiding duplicate state updates.

Manager rule:
> Patterns are tools, not requirements. Use the smallest architecture that keeps state ownership obvious.

---

# 3. Game Feel / Platformer Control

## Game Feel: A Game Designer's Guide to Virtual Sensation — Steve Swink
Publisher: Morgan Kaufmann / Elsevier / CRC editions
Publisher page:
https://shop.elsevier.com/books/game-feel/swink/978-0-12-374328-2

Relevant concepts to research:
- input response
- response metrics
- context and constraints
- movement feel
- ancillary feedback
- sound as feedback
- measuring feel instead of tuning only by intuition

Application to CatJump:
- normal jump must remain satisfying before adding complexity
- double jump should feel distinct without destroying the base jump
- bird warning must communicate danger clearly
- landing and Energy spend need readable feedback

Manager questions:
- What is the input-to-visible-response delay?
- Can the player predict the jump arc?
- Does double jump feel like an intentional tool or a panic button with no readable cost?
- Is failure attributable to player choice rather than unclear feedback?

---

# 4. General Game Design / Scope / Experience

## The Art of Game Design: A Book of Lenses, Third Edition — Jesse Schell
Publisher page:
https://www.routledge.com/The-Art-of-Game-Design-A-Book-of-Lenses-Third-Edition/Schell/p/book/9781138632059

Use lenses selectively. Especially useful themes for this project:
- player experience
- challenge
- skill
- meaningful choice
- feedback
- simplicity/elegance
- pacing

Manager application:
Before adding a mechanic ask:
- What player experience does this create?
- Is it already created by an existing mechanic?
- Does it deepen the climb or merely add more rules?

If it only adds content burden, keep it out of scope.

## Level Up! The Guide to Great Video Game Design — Scott Rogers
Publisher: Wiley
Reference/preview listing:
https://books.google.com/books?id=MHmwtAEACAAJ

Relevant topics:
- communicating mechanics
- player actions
- level progression
- camera
- documentation
- approachable game-design workflow

Manager application:
Use it as a general practical design reference, especially when structuring tutorial/teaching progression.

---

# 5. Systems Thinking / Loops

## Advanced Game Design: A Systems Approach — Michael Sellers
Publisher page:
https://www.pearson.com/en-us/subject-catalog/p/advanced-game-design-a-systems-approach/P200000009594

Especially relevant topics:
- systems thinking
- game loops
- defining parts and relationships
- balancing systems
- designing the whole experience

Application to CatJump:
Model the loop explicitly:

`climb → spend Energy / avoid hazards → possible fight → consequence/recovery → resume climb`

The manager should check whether a new mechanic strengthens this loop or creates a disconnected subgame.

---

# 6. Balance

## Game Balance — Ian Schreiber & Brenda Romero
Publisher page:
https://www.routledge.com/link/link/p/book/9781032034003

Relevant to:
- Energy maximum
- double-jump cost
- bird frequency
- bird reaction window
- combat damage/HP
- 4–5 floor penalty severity
- 9-life economy
- time cost of combat

Manager should create small balance tables instead of guessing values.

Example variables to model:
- average normal-jump route length before double jump becomes attractive
- double jumps available per full Energy bar
- expected fights per run
- expected bird encounters per run
- expected fight duration
- average floors lost after an Energy fight loss
- expected lives remaining at victory for novice vs competent players

Do not optimize for mathematical symmetry. Optimize for readable difficulty and recovery.

---

# 7. Level Design / Vertical Pacing

## An Architectural Approach to Level Design, Second Edition — Christopher W. Totten
Publisher page:
https://www.routledge.com/Architectural-Approach-to-Level-Design-Second-edition/Totten/p/book/9781351116305

Relevant concepts:
- spatial readability
- player-focused layout
- teaching spaces
- rhythm and pacing
- use of landmarks and readable affordances

Application to CatJump:
- each traversal instance should communicate where the player can safely land
- early floors should teach one concept at a time
- later floors should combine learned concepts rather than introduce constant new controls
- vertical progression should visually communicate advancement

## Level Design: Concept, Theory, and Practice — Rudolf Kremers
Reference listing:
https://books.google.com/books/about/Level_Design.html?id=YCLuuAEACAAJ

Relevant topics:
- interactivity
- pacing
- sensory perception
- immersion/readability
- practical level-design tools

Use as a secondary reference for route pacing and readability.

---

# 8. Formal Design Analysis

## MDA: A Formal Approach to Game Design and Game Research — Hunicke, LeBlanc, Zubek
AAAI paper:
https://aaai.org/papers/ws04-04-001-mda-a-formal-approach-to-game-design-and-game-research/

Use MDA as a compact design sanity check:

### Mechanics
- jump
- double jump
- Energy
- bird collision
- turn-based fight
- lives
- floor penalty

### Dynamics
- saving Energy vs spending it to recover a jump
- avoiding birds to protect time/lives
- fight interruption changing route rhythm
- recovery after failure

### Intended aesthetics/experience
- tension
- playful risk
- mastery
- relief after recovery
- arcade urgency

Manager rule:
If mechanics are creating dynamics that contradict the intended experience, tune or remove them instead of adding more mechanics to compensate.

---

# 9. Production / Session Management

## The Game Production Handbook — Heather Maxwell Chandler
Reference listing:
https://books.google.com/books/about/The_Game_Production_Handbook.html?id=MUOG6CE08ucC

Relevant to:
- task breakdown
- production pipeline
- milestone discipline
- team communication
- managing change

Application to this AI workflow:
- one system per coder session
- explicit Definition of Done
- evidence-based completion
- regression review
- handoff documentation
- do not start the next feature while current work is unstable

---

# 10. Project-Specific Research Assignments

The manager should research these questions before freezing the relevant session handoff.

## A. Double Jump + Energy

Research:
- how double-jump strength relative to normal jump affects route readability
- how many double jumps per Energy bar produce meaningful choice without constant interruption
- whether Energy should be discrete charges or a bar for this game's scope

Deliverable:
- proposed values
- reasoning
- test matrix
- fallback tuning range

## B. Energy-Depletion Encounter

Research:
- how interruption frequency affects platformer pacing
- recovery mechanics after failed secondary challenge

Deliverable:
- Energy fight frequency target
- post-loss Energy rule that avoids retrigger loop
- exact floor-loss behavior

## C. Bird Hazard Fairness

Research:
- reaction-time telegraphing
- spawn fairness in fast arcade hazards
- lane/position constraints

Deliverable:
- warning duration
- speed
- spawn interval
- protected spawn states
- collision radius philosophy

## D. Minimal Turn-Based Combat

Research:
- micro turn-based systems with very small action sets
- encounter duration
- readable risk/reward with 3 HP

Deliverable:
- full combat rules on one page
- exact player actions
- exact enemy logic
- damage values
- fight duration target
- no extra RPG systems

## E. Vertical Level Pacing

Research:
- teach → test → combine structure
- vertical landmarks/progress feedback
- recovery routes after mistakes

Deliverable:
- difficulty-band plan
- floor-count recommendation
- traversal-instance distribution

## F. Cross-Scene State QA

Research:
- Godot scene transition/state persistence best practices
- signals/state ownership

Deliverable:
- authoritative state ownership diagram
- transition contract
- test matrix for repeated fight entry/exit

---

# 11. Source Quality Rules

Priority order:

1. Godot official docs for engine facts.
2. Original papers / authors / publisher pages for design references.
3. Reputable GDC talks / established design resources for applied examples.
4. Community tutorials only when official material does not answer the implementation question.

When community advice conflicts with Godot 4.7 documentation, use the Godot 4.7 documentation unless there is a verified engine bug/workaround.

Do not base architecture on a random tutorial because it ranks highly in search.

---

# 12. What Research Is NOT For

Research should reduce uncertainty, not inflate scope.

The manager must not return from research with:
- ten new mechanics
- a meta-progression system
- an inventory because another game has one
- a procedural generator because object pooling exists
- a deep RPG combat tree because turn-based games can support one

For this project, good research produces **fewer, clearer decisions**.

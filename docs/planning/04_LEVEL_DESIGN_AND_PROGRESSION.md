# Human Must Never Know - Level Design and Progression

The initial production level is a finite, manually authored 50-tier climb. The four-column recycler is a test harness, not a content pipeline.

## Authoring model

- Create a production Scenes/Levels/ClimbLevel.tscn. Under Traversal, instance Scenes/Gameplay/FloorTier.tscn fifty times as Floor_001 through Floor_050. Each reusable FloorTier has an exported floor_number, an editor-visible Traversal child for gameplay instances, and a RespawnAnchor Marker2D child. The anchor position is the Player root's exact safe standing position; it inherits the floor number from its FloorTier parent.
- Keep a readable four-column facade reference from the current prototype: windows centered near x=220, 500, 780, and 1060; initial vertical tier spacing is 100 px. Deviations are allowed when the specific jump is tested and remains fair.
- Place a Scenes/Gameplay/StandardWindow.tscn or an existing Environment scene as each visible/standable object. Use instance naming such as Floor_016_Window_Left or Floor_025_FireEscapePlatform.
- Keep one safe RespawnAnchor inside each FloorTier at the main route landing. Do not duplicate floor_number on the Marker2D; the parent FloorTier is its identity.
- Keep all floor content scene-authored. No script creates floor/platform hierarchies or randomizes the route.
- Use static polygon/ColorRect/Line2D placeholders until mechanics and layout are accepted. Every collision surface must be visible and understandable.

## Floor plan

| Floors | Learning purpose | Placement and system rules |
|---|---|---|
| 1-5 | Teach left/right, normal jump, land, camera, floor counter. | Floor 1 is a broad safe starting platform; the first upward climb landing is Floor 2. Continue with wide StandardWindows and one normal-jump route per tier. No Birds, pipes, or required Energy. |
| 6-10 | Teach optional double jump and Energy cost. | Keep the free route; add one conspicuous optional shortcut or recovery line where a double jump saves a jump/position. HUD explains current/max Energy. Still no Bird until floor 16. |
| 11-15 | Introduce PipeClimb as a slower vertical route and outdoor AC as a narrow choice. | Put a broad StandardWindow/FireEscapePlatform alternate nearby. A missed pipe entry must not cause a fall with no recovery. |
| 16-20 | Introduce a Bird in an otherwise familiar layout. | First spawn requires both floor 16 reached and the 25-second warm-up. Floor 16 warning has space to move left or right. Introduce no additional traversal type during the first Bird encounter. |
| 21-25 | Teach broader balcony/fire-escape landing and five-floor knockback. | Balcony and fire-escape platforms are broad, obvious safe landings. Floor 25 anchor gives a recognizable rest landmark. |
| 26-30 | Add FireEscapeStair as a sequence of visible short step platforms. | Steps offer an alternate way upward; each is a normal platform collision. Keep a regular window route in parallel. |
| 31-35 | Combine pipes, ACs, stairs, balconies, and Bird warnings. | Narrow pieces can be optional. At least one broad landing per three-floor stretch; use composition to require attention without requiring double jumps. |
| 36-40 | Raise horizontal route choices and mild Energy pressure. | Remove a few windows to make meaningful route decisions, but keep at least one normal-jump route. A double jump can recover a poor launch; it cannot gate advancement. |
| 41-45 | Combine known patterns and prepare the last ascent. | Put a safe rest landing at floor 45 and visually show the roof goal. Do not add an enemy or new traversal mechanic. |
| 46-49 | Final climb. | Use the hardest already-taught window/AC/stair combinations; warn Birds as usual. Disable new Bird spawns at floor 49 to protect the roof approach. |
| 50 | Finish. | Wide rooftop landing and Goal Area2D. No new challenge. Enter Victory once; stop hazards and timer. |

## Floor-by-floor layout brief

This table fixes the teaching order and route purpose for the first authored pass. L1-L4 refer to the four facade columns in the authoring model above. It describes intended scene composition, not pixel-perfect placements; actual takeoff and landing geometry must be verified with the preserved controller.

| Floor | Required safe route | Optional route or lesson |
|---:|---|---|
| 1 | Wide ground/start landing spanning the facade; Player begins here. | Teach the camera and floor label without a jump. |
| 2 | Broad StandardWindow in L2. | One simple normal jump from the start. |
| 3 | Broad StandardWindow in L3 with an easy L2 fallback ledge. | Teach a one-column horizontal transfer. |
| 4 | Windows in L2 and L3. | Let the player choose a short return or direct landing. |
| 5 | Balcony landmark in L2 or L3 with a wide safe surface. | First clear rest landmark; no hazard. |
| 6 | Broad StandardWindow in the next reachable column. | Add a visible upper window shortcut reachable with double jump; the lower normal-jump route remains. |
| 7 | StandardWindow in L3 with L2/L4 landing alternatives. | Show that one double jump can recover height without being required. |
| 8 | Two broad windows making an ordinary jump route. | Place one farther optional window as a double-jump shortcut. |
| 9 | StandardWindow route with comfortable landing overlap. | A short safe route and a slightly faster optional route. |
| 10 | Balcony landmark and broad landing. | Pause point before the first traversal interaction. |
| 11 | StandardWindow route beside a pipe with visible top and bottom endpoints. | Introduce PipeClimb; a missed entry lands on a broad lower surface. |
| 12 | Broad window at the top of the pipe route. | Teach holding Up, releasing safely, and exiting by jump. |
| 13 | StandardWindow safe route, with one ACUnit in a neighboring column. | First narrow AC landing is optional. |
| 14 | Windows at two adjacent columns; the pipe may connect one lower route. | Combine a known pipe with a normal jump, without time pressure. |
| 15 | Balcony landmark and broad landing. | Safe rest before the first Bird phase. |
| 16 | Wide windows and open movement space in all four lanes. | First Bird can begin only after floor 16 is reached and the 25-second warm-up completes; introduce no new traversal here. |
| 17 | Broad StandardWindow route with a nearby alternate column. | Repeat the dodge without adding a new platform type. |
| 18 | Windows on the safe route plus one AC option. | A Bird warning can occur; keep at least one clear escape direction. |
| 19 | StandardWindow route with one ACUnit shortcut. | Optional tighter landing; no required double jump. |
| 20 | Balcony landmark. | Broad recovery landing after the first Bird exposure. |
| 21 | FireEscapePlatform in a reachable column. | Introduce the broad fire-escape rest surface. |
| 22 | StandardWindow route to the next floor. | Include a FireEscapePlatform alternate landing. |
| 23 | Two adjacent windows and a broad platform option. | Mix a Bird warning into a familiar layout. |
| 24 | FireEscapePlatform as the safe landing. | Optional double-jump shortcut between neighboring columns. |
| 25 | Balcony landmark and anchor. | Make the five-floor retreat destination visually recognizable. |
| 26 | Broad StandardWindow route; one FireEscapeStair segment sits beside it. | First stair segment has visible, individually collidable steps. |
| 27 | Continue the stair route into the next FloorTier with a wide window alternative. | Teach repeated stair segments as a 2-3-floor vertical route. |
| 28 | StandardWindow safe route with one AC landing. | Combine AC and stair choices; keep the AC optional. |
| 29 | Adjacent broad windows. | Bird warning may arrive during an otherwise familiar jump. |
| 30 | Balcony landmark and broad rest. | End the first mixed-traversal block. |
| 31 | StandardWindow route beside a connected pipe. | Pipe is a slower alternate to a double-jump shortcut. |
| 32 | FireEscapeStair segment with a StandardWindow landing at its top. | Offer two readable paths between columns. |
| 33 | Broad landing followed by a one-column transfer. | Bird warning can test route reading; keep left/right escape space. |
| 34 | Balcony landmark with an AC option nearby. | Optional narrow landing, safe route stays broad. |
| 35 | Broad platform at a central column. | Rest landmark before the more varied upper climb. |
| 36 | Windows alternate across two adjacent columns. | Remove one redundant window but preserve a normal-jump route. |
| 37 | FireEscapeStair segment with broad window fallback. | Reuse learned stair timing; no new control. |
| 38 | PipeClimb beside an ordinary window route. | Optional shortcut; no Energy cost and no mandatory pipe attachment. |
| 39 | Broad StandardWindow route with an open warning lane. | Bird can combine with a familiar transfer; never place warning at a locked jump. |
| 40 | Balcony landmark and safe anchor. | Rest before the final ten-floor block. |
| 41 | Windows with one adjacent-column transfer. | Increase spacing modestly only if the verified jump remains fair. |
| 42 | FireEscapeStair route beside a broad window route. | Combine stairs with a known landing type. |
| 43 | StandardWindow safe route and one AC alternative. | Optional double jump can skip a landing, never required. |
| 44 | Broad landing with a Bird warning lane and open dodge space. | Combine only already-taught Bird and platform rules. |
| 45 | Balcony landmark and anchor. | Last large rest point before the roof approach. |
| 46 | StandardWindow route across one or two familiar columns. | Require attention through spacing, not a new mechanic. |
| 47 | FireEscapeStair segment, with StandardWindow fallback. | Keep the final shortcut optional and readable. |
| 48 | Broad StandardWindow route with clear movement room. | Bird may still occur; its warning and dodge rules remain unchanged. |
| 49 | Wide safe landing directly below the roof. | Cancel pending warnings and remove a live Bird; start no new Bird. |
| 50 | Wide rooftop landing with RooftopGoal Area2D. | No new challenge or hazard; one-shot Victory transition. |

## Traversal vocabulary

| Scene | Gameplay purpose | Collision/behavior | Placement rule |
|---|---|---|---|
| Standard Window | Main reliable jump target and rest point. | Reuse existing StaticBody2D, visible sill, one-way CollisionShape2D. Existing collision is 240 px wide and 16 px deep. | Most common piece; standard landing distance. Use repeated windows to teach route. |
| PipeClimb | Optional vertical shortcut with a time trade-off. | Existing ClimbArea detects Player. While overlapping, holding Up climbs at exported 160 px/s, gravity is suspended, and horizontal input or jump exits. No Energy cost. One attached pipe does not reset the double-jump allowance. | Anchor its visible pipe to the facade; top/bottom must connect to visible safe landings. Never make a pipe the only recovery from a bad jump. |
| AC Unit | Narrow but stable step for a tighter line. | Existing 144 px one-way StaticBody2D landing. | Use as optional route or one-step connector; test reach to/from neighbor with current player hitbox. |
| Fire Escape Platform | Wider, safe alternate landing/rest. | Existing 210 px one-way StaticBody2D. | Place at tier breaks and stable route choices; frequent enough for readable recovery. |
| Fire Escape Stair | A visible stepped shortcut, not a new button mode. | Preserve stair visual; add distinct step StaticBody2D and CollisionShape2D children. Steps are one-way landings; player jumps them normally. Existing interaction Area is not a stand surface. | One reusable stair segment spans one FloorTier. Place segments in consecutive FloorTier instances for a 2-3 tier route; keep another normal route. |
| Balcony | Landmark and broad rest/respawn landing. | Existing 200 px one-way StaticBody2D. | Use at floors 5, 10, 15... as visible pacing/rest landmarks, with a separate respawn marker at the main route landing. |

All scene instances should be movable, duplicable, replaceable, and collision-editable in the Inspector. Export only tuning values that affect play (for example pipe climb speed); use actual child CollisionShape2D objects for geometry.

## Reachability and fair placement

- Keep a known-safe route from Floor 1 to Roof that uses only normal jumps and the special pipe hold where a clearly connected pipe route is intended. Double jump is never required on the main route.
- The current Player baseline has a theoretical rise of about 128 px for the -610 jump and 1450 rising gravity before considering collisions. Treat 100 px as the initial vertical tier pitch, not a guaranteed jump result. The higher fall gravity, hitboxes, pipe, and platform width change the playable envelope.
- For every new platform pair, test the jump from both takeoff edges and with the player at rest. Do not judge reach from center-to-center distance alone; StandardWindow has a 240 px collision surface, while AC is only 144 px.
- Do not place a landing under an overhang that blocks the cat's jump arc unless the layout has an alternate route.
- A Bird cannot be telegraphed in a lane with no reachable escape side, or at a point where a required jump has locked the player into unavoidable collision. Warnings must be visible while Climb Mode is active.
- Keep the roof goal outside Bird spawner lanes and disable new spawns at floor 49.

## Respawn placement

Each floor's RespawnAnchor is positioned at the Player root's exact safe standing position on its main-route landing. On defeat, target max(1, last_landed_floor - 5) exactly. This produces an exact five-floor drop, clamped at floor 1. The nearest valid surface is not inferred from arbitrary geometry; the author sets and visually checks every anchor. Floor 1's anchor is the fallback. The broad floor-1 platform spans the bottom of the playable facade, so a missed jump can land safely without adding another life-loss rule.

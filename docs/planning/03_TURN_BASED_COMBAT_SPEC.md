# Human Must Never Know - Turn-Based Combat Specification

This is the complete initial combat design. Developer AI must implement these rules and must not invent another combat system.

## Purpose and length

Combat is a brief consequence inside a climbing run. One reusable Fight scene serves both Energy and Bird encounter reasons. An Energy Fight presents the abstract opponent **Exhaustion** as a simple shadow/energy silhouette; a Bird Fight presents the colliding Bird. These are presentation variants of the same opponent rules, not separate enemy types. Encounters have no inventory, progression, equipment, randomness, status effects, or loot. Target 7-12 player actions, usually under 20 seconds of decision/animation time.

## State

Each new fight starts with:
- Player Fight HP: 3.
- Opponent HP: 6.
- Player action state: waiting for one valid action.
- Opponent intent: STRIKE on turns 1, 3, 5, 7, 9, and 11; RECOVER on turns 2, 4, 6, 8, 10, and 12.
- Turn index: 1.
- Result: unset.

Fight HP belongs only to the Fight scene. It is not stored as a Life, and it never carries between encounters.

## Player actions

1. **Scratch:** deals 1 damage to the opponent. It is available on both STRIKE and RECOVER.
2. **Brace:** deals no damage and blocks the current opponent hit. It is available only on a STRIKE turn. It advances the turn normally.

The visible buttons are labeled Scratch (Z) and Brace (X). Add InputMap actions `fight_scratch` (Z) and `fight_brace` (X); mouse activation remains available. There are only these two actions. No miss chance, critical hit, random damage, healing, or Energy action exists.

## Exact turn order

The Fight UI shows the current opponent intent before enabling player input.

1. Player selects Scratch or Brace.
2. Scratch subtracts 1 opponent HP. If opponent HP reaches 0, end immediately in victory; the defeated opponent cannot retaliate.
3. If the opponent remains alive and intent is STRIKE: Scratch receives 1 damage; Brace receives 0 damage.
4. If Fight HP reaches 0, end immediately in defeat.
5. Otherwise advance the turn index and toggle STRIKE/RECOVER.

On RECOVER, no opponent damage is dealt. Brace is disabled there and its disabled state says "No incoming strike." On STRIKE, intent is clearly visible; Brace remains a valid answer until the player acts.

## Why the numbers work

With six opponent HP, the player needs six successful Scratches. Without Brace, the third nonlethal Strike response reaches zero Fight HP before the sixth Scratch. A single Brace on a Strike delays that response and lets the player win in seven actions: six Scratches and one Brace. Using Brace on every Strike is safe but slow; it ends after at most 12 actions because six RECOVER actions still permit the required six Scratches. The result is a small readable timing choice rather than an RPG build.

## Encounter presentation

Scenes/UI/Fight.tscn is a reusable full-screen Control scene, instanced over the frozen climbing world. It receives an encounter reason before it becomes interactive:
- Energy: title the opponent Exhaustion and use a simple abstract shadow/energy silhouette.
- Bird: display Bird and use Bird's visible placeholder silhouette.

Both reasons use the same 6 HP, 1 damage, and Strike/Recover sequence. The reason is presentation/context only. No second enemy ruleset is permitted in the first release.

## UI and feedback

- Show three distinct Fight HP pips, six opponent HP pips, the current turn number, and a large STRIKE or RECOVER intent.
- Show Scratch and Brace buttons with the exact InputMap actions above. Keyboard focus must be visible; mouse use must also work.
- Scratch gives one clear hit cue and removes exactly one opponent pip.
- Incoming Strike has a wind-up cue. Brace gives a distinct block cue and no HP loss.
- Damage flashes the player HP display. Zero Fight HP or zero opponent HP uses a short outcome pause, then emits one result.
- The Energy/Lives/Floor/Timer HUD may remain visible in reduced form behind/around Fight UI, but Fight HP stays in the Fight scene.
- Do not require rapid real-time button presses. Run clock continues while a choice is pending; the game can be paused.

## Ownership and reusable architecture

FightController.gd, attached to Scenes/UI/Fight.tscn's root Control, owns Fight HP, opponent HP, turn index, intent, action validation, and the single completion signal. Its only outward contract is the encounter reason supplied before play and one fight_finished(victory) signal. RunController owns the encounter reason, mode lock, and consequences. The Fight scene does not alter Energy, Lives, floor, player position, or the run timer.

## Edge cases

- Ignore input after a result is set.
- Reject Brace on Recover and any unknown action without advancing the turn.
- If the opponent is defeated by Scratch, do not apply the same turn's Strike.
- If Fight HP reaches zero, emit defeat once; do not also emit victory.
- Cancel queued UI actions when Fight closes.
- Reset all fight state when a new fight instance starts.
- If the scene is paused, the Fight animation and the run timer also stop.

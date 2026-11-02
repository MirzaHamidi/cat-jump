class_name FightController
extends Control

signal fight_finished(result: FightResult)

enum Action { HISS, CLAW, RUN_AWAY, MERCY }
enum FightResult { VICTORY, DEFEAT, RETREAT }
enum EncounterReason { ENERGY, BIRD }
enum OpponentIntent { STRIKE, RECOVER }

const STARTING_FIGHT_HP := 3
const STARTING_OPPONENT_HP := 6
const STARTING_HISSES := 3
const MAX_RESOLVE := 2
const OUTCOME_DELAY_SECONDS := 0.8

@export_group("Fight Pacing")
@export_range(0.05, 0.75, 0.05) var action_beat_seconds: float = 0.24
@export_range(0.05, 0.75, 0.05) var response_beat_seconds: float = 0.24

var encounter_reason: EncounterReason = EncounterReason.ENERGY
var fight_hp := STARTING_FIGHT_HP
var opponent_hp := STARTING_OPPONENT_HP
var hisses_remaining := STARTING_HISSES
var resolve := 0
var turn_index := 1
var fight_result: FightResult = FightResult.VICTORY
var has_result := false

var _retreat_confirmation_armed := false
var _result_emitted := false
var _is_resolving := false
var _strike_response_pending := false

@onready var title_label: Label = $TitleLabel
@onready var opponent_name_label: Label = $OpponentNameLabel
@onready var opponent_panel: ColorRect = $OpponentPanel
@onready var turn_label: Label = $TurnLabel
@onready var intent_label: Label = $IntentLabel
@onready var intent_hint_label: Label = $IntentHintLabel
@onready var energy_silhouette: Node2D = $EnergySilhouette
@onready var bird_silhouette: Node2D = $BirdSilhouette
@onready var fight_status_label: Label = $FightStatusLabel
@onready var feedback_label: Label = $FeedbackLabel
@onready var retreat_cost_label: Label = $RetreatCostLabel
@onready var hiss_hint_label: Label = $HissHintLabel
@onready var claw_hint_label: Label = $ClawHintLabel
@onready var run_away_hint_label: Label = $RunAwayHintLabel
@onready var mercy_hint_label: Label = $MercyHintLabel
@onready var hiss_button: Button = $HissButton
@onready var claw_button: Button = $ClawButton
@onready var run_away_button: Button = $RunAwayButton
@onready var mercy_button: Button = $MercyButton
@onready var outcome_label: Label = $OutcomeLabel
@onready var outcome_pause: Timer = $OutcomePause
@onready var action_pacing: Timer = $ActionPacing


func configure_encounter(reason: int) -> void:
	if reason == EncounterReason.ENERGY or reason == EncounterReason.BIRD:
		encounter_reason = reason as EncounterReason
	else:
		push_error("FightController received an unknown encounter reason; using Energy.")
		encounter_reason = EncounterReason.ENERGY
	if is_node_ready():
		_update_display()


func _ready() -> void:
	_reset_fight()
	if not outcome_pause.timeout.is_connected(_on_outcome_pause_timeout):
		outcome_pause.timeout.connect(_on_outcome_pause_timeout)
	if not action_pacing.timeout.is_connected(_on_action_pacing_timeout):
		action_pacing.timeout.connect(_on_action_pacing_timeout)
	_update_display()
	_ensure_valid_focus()


func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	var key_event := event as InputEventKey
	if key_event.echo:
		if key_event.is_action("ui_accept"):
			get_viewport().set_input_as_handled()
		return
	if has_result or _is_resolving:
		return
	if key_event.is_action_pressed("ui_cancel") and _retreat_confirmation_armed:
		_cancel_retreat_confirmation()
		get_viewport().set_input_as_handled()
		return
	if key_event.physical_keycode == KEY_A:
		_select_relative(-1)
		get_viewport().set_input_as_handled()
		return
	if key_event.physical_keycode == KEY_D:
		_select_relative(1)
		get_viewport().set_input_as_handled()
		return

	var shortcut_action := -1
	if key_event.is_action_pressed("fight_hiss"):
		shortcut_action = Action.HISS
	elif key_event.is_action_pressed("fight_claw"):
		shortcut_action = Action.CLAW
	elif key_event.is_action_pressed("fight_run_away"):
		shortcut_action = Action.RUN_AWAY
	elif key_event.is_action_pressed("fight_mercy"):
		shortcut_action = Action.MERCY
	if shortcut_action >= 0:
		take_action(shortcut_action)
		get_viewport().set_input_as_handled()


func take_action(action: int) -> bool:
	if has_result or _is_resolving:
		return false
	if _retreat_confirmation_armed and action != Action.RUN_AWAY:
		_cancel_retreat_confirmation()
		return false
	if not _is_action_available(action):
		return false

	match action:
		Action.HISS:
			_is_resolving = true
			hisses_remaining -= 1
			resolve = mini(resolve + 1, MAX_RESOLVE)
			feedback_label.text = "Hiss blocks the incoming Strike. Resolve +1; no Fight HP lost."
			_start_action_pacing(action_beat_seconds)
			return true
		Action.CLAW:
			_is_resolving = true
			opponent_hp = maxi(opponent_hp - 1, 0)
			if opponent_hp == 0:
				feedback_label.text = "The Claw ends the Fight before retaliation."
				_finish(FightResult.VICTORY)
				return true
			if current_intent() == OpponentIntent.STRIKE:
				_strike_response_pending = true
				feedback_label.text = "Claw deals 1. The surviving opponent's Strike is next."
			else:
				feedback_label.text = "Claw deals 1 during Recover. No retaliation."
			_start_action_pacing(action_beat_seconds)
			return true
		Action.RUN_AWAY:
			if not _retreat_confirmation_armed:
				_retreat_confirmation_armed = true
				feedback_label.text = "Confirm Run Away to accept the cost above. Press it again; Escape or A/D cancels."
				_update_display()
				return true
			_retreat_confirmation_armed = false
			_finish(FightResult.RETREAT)
			return true
		Action.MERCY:
			feedback_label.text = "Mercy ends the Fight as VICTORY. The opponent survives; prior Claws still count as damage."
			_finish(FightResult.VICTORY)
			return true
	return false


func current_intent() -> OpponentIntent:
	return OpponentIntent.STRIKE if turn_index % 2 == 1 else OpponentIntent.RECOVER


func _reset_fight() -> void:
	fight_hp = STARTING_FIGHT_HP
	opponent_hp = STARTING_OPPONENT_HP
	hisses_remaining = STARTING_HISSES
	resolve = 0
	turn_index = 1
	has_result = false
	_result_emitted = false
	_retreat_confirmation_armed = false
	_is_resolving = false
	_strike_response_pending = false
	fight_result = FightResult.VICTORY
	feedback_label.text = "Choose an action."
	outcome_label.hide()
	outcome_pause.stop()
	action_pacing.stop()


func _is_action_available(action: int) -> bool:
	if has_result or _is_resolving:
		return false
	match action:
		Action.HISS:
			return current_intent() == OpponentIntent.STRIKE and hisses_remaining > 0
		Action.CLAW:
			return true
		Action.RUN_AWAY:
			return current_intent() == OpponentIntent.RECOVER and resolve >= 1
		Action.MERCY:
			return current_intent() == OpponentIntent.RECOVER and resolve == MAX_RESOLVE and opponent_hp <= 2
	return false


func _advance_turn() -> void:
	_is_resolving = false
	turn_index += 1
	_retreat_confirmation_armed = false
	_update_display()
	_ensure_valid_focus()


func _start_action_pacing(duration: float) -> void:
	action_pacing.start(maxf(duration, 0.01))
	_update_display()


func _on_action_pacing_timeout() -> void:
	if has_result or not _is_resolving:
		return
	if _strike_response_pending:
		_strike_response_pending = false
		fight_hp = maxi(fight_hp - 1, 0)
		if fight_hp == 0:
			feedback_label.text = "The opponent's Strike lands after the Claw."
			_update_display()
			_finish(FightResult.DEFEAT)
			return
		feedback_label.text = "The opponent's Strike lands for 1. Your next turn follows this beat."
		_update_display()
		_start_action_pacing(response_beat_seconds)
		return
	_advance_turn()


func _finish(result: FightResult) -> void:
	if has_result:
		return
	has_result = true
	_is_resolving = false
	_strike_response_pending = false
	action_pacing.stop()
	fight_result = result
	_retreat_confirmation_armed = false
	outcome_label.text = FightResult.keys()[result]
	outcome_label.show()
	_update_display()
	outcome_pause.wait_time = OUTCOME_DELAY_SECONDS
	outcome_pause.start()


func _on_outcome_pause_timeout() -> void:
	if not has_result or _result_emitted:
		return
	_result_emitted = true
	fight_finished.emit(fight_result)


func _update_display() -> void:
	if not is_node_ready():
		return
	var bird_encounter := encounter_reason == EncounterReason.BIRD
	title_label.text = "FIGHT"
	opponent_name_label.text = "BIRD" if bird_encounter else "EXHAUSTION"
	energy_silhouette.visible = not bird_encounter
	bird_silhouette.visible = bird_encounter
	turn_label.text = "TURN %02d" % turn_index
	var strike_turn := current_intent() == OpponentIntent.STRIKE
	intent_label.text = "STRIKE" if strike_turn else "RECOVER"
	intent_hint_label.text = "Incoming Strike. Hiss blocks it; surviving Claw costs 1 Fight HP." if strike_turn else "Recover turn. Claw has no retaliation; Run Away and Mercy may be available."
	opponent_panel.color = Color("#d6d6d6") if strike_turn else Color("#dddddd")
	intent_label.add_theme_color_override("font_color", Color("#a45143") if strike_turn else Color("#666666"))
	fight_status_label.text = "HISSES %d/%d     RESOLVE %d/%d" % [hisses_remaining, STARTING_HISSES, resolve, MAX_RESOLVE]
	retreat_cost_label.text = "RETREAT COST — Energy becomes 50; drop 5 floors; lose no Life." if not bird_encounter else "RETREAT COST — Lose 1 Life; drop 5 floors; keep Energy."

	var hiss_available := _is_action_available(Action.HISS)
	var claw_available := _is_action_available(Action.CLAW)
	var retreat_available := _is_action_available(Action.RUN_AWAY)
	var mercy_available := _is_action_available(Action.MERCY)
	hiss_button.disabled = not hiss_available
	claw_button.disabled = not claw_available
	run_away_button.disabled = not retreat_available
	mercy_button.disabled = not mercy_available
	run_away_button.text = "CONFIRM RETREAT" if _retreat_confirmation_armed else "RUN AWAY"

	hiss_hint_label.text = "STRIKE only · blocks hit · +1 Resolve." if hiss_available else ("Disabled: all Hisses used." if hisses_remaining <= 0 else "Disabled: STRIKE only.")
	claw_hint_label.text = "Any turn · foe -1 HP · Strike may cost 1 HP." if claw_available else "Disabled: Fight has ended."
	if retreat_available:
		run_away_hint_label.text = "Press again to confirm; Escape/A/D cancels." if _retreat_confirmation_armed else "RECOVER + Resolve 1+; confirm to retreat."
	else:
		run_away_hint_label.text = "Disabled: RECOVER + Resolve 1+ required." if resolve < 1 else "Disabled: RECOVER only."
	if mercy_available:
		mercy_hint_label.text = "RECOVER + Resolve 2 + foe ≤2 HP; prior damage remains; foe survives."
	elif current_intent() != OpponentIntent.RECOVER:
		mercy_hint_label.text = "Disabled: RECOVER only."
	elif resolve < MAX_RESOLVE:
		mercy_hint_label.text = "Disabled: need Resolve 2."
	else:
		mercy_hint_label.text = "Disabled: foe must have ≤2 HP."

	for index in range(1, STARTING_OPPONENT_HP + 1):
		var opponent_pip := get_node_or_null("OpponentHPPips/OpponentPip%d" % index) as ColorRect
		if opponent_pip != null:
			opponent_pip.color = Color("#666666") if index <= opponent_hp else Color("#cccccc")
	for index in range(1, STARTING_FIGHT_HP + 1):
		var player_pip := get_node_or_null("PlayerHPPips/PlayerPip%d" % index) as ColorRect
		if player_pip != null:
			player_pip.color = Color("#666666") if index <= fight_hp else Color("#cccccc")


func _ensure_valid_focus() -> void:
	if not is_node_ready() or has_result or _is_resolving:
		return
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner is Button and focus_owner in _action_buttons() and not (focus_owner as Button).disabled:
		return
	for button in _action_buttons():
		if not button.disabled and button.visible:
			button.grab_focus()
			return


func _select_relative(direction: int) -> void:
	if has_result or _is_resolving:
		return
	if _retreat_confirmation_armed:
		_cancel_retreat_confirmation()
	var buttons := _action_buttons()
	var focus_owner := get_viewport().gui_get_focus_owner()
	var current_index := buttons.find(focus_owner)
	if current_index < 0:
		current_index = 0 if direction >= 0 else buttons.size() - 1
	for step in range(1, buttons.size() + 1):
		var next_index := posmod(current_index + direction * step, buttons.size())
		if not buttons[next_index].disabled:
			buttons[next_index].grab_focus()
			return


func _cancel_retreat_confirmation() -> void:
	if not _retreat_confirmation_armed:
		return
	_retreat_confirmation_armed = false
	feedback_label.text = "Run Away canceled. The turn is unchanged. Choose an action."
	_update_display()
	_ensure_valid_focus()


func _action_buttons() -> Array[Button]:
	return [hiss_button, claw_button, run_away_button, mercy_button]


func _on_hiss_button_pressed() -> void:
	take_action(Action.HISS)


func _on_claw_button_pressed() -> void:
	take_action(Action.CLAW)


func _on_run_away_button_pressed() -> void:
	take_action(Action.RUN_AWAY)


func _on_mercy_button_pressed() -> void:
	take_action(Action.MERCY)

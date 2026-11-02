class_name DogBossArena
extends Node2D
## Narrow real-time graybox. All timing/HP values are provisional.

signal encounter_finished(victory: bool)

enum State { INTRO, CHARGE_WINDUP, CHARGE, IMPACT, RECOVER, BITE_APPROACH, BITE_WINDUP, BITE_ACTIVE, BITE_RECOVER, BARK, OWNER_ENTER, OWNER_WINDUP, OWNER_ACTIVE, OWNER_GAP, OWNER_RECOVER, FINISHED }

@export_group("Provisional Boss Values")
@export_range(1, 30) var maximum_hp: int = 6
@export var charge_speed: float = 480.0
@export var charge_windup: float = 0.85
@export var impact_duration: float = 0.28
@export var recovery_duration: float = 0.8
@export var charge_timeout: float = 3.0
@export_range(1, 9) var player_hit_cost: int = 1
@export var hit_grace: float = 0.8
@export_range(0, 29) var phase_two_hp: int = 4
@export_range(0, 28) var phase_three_hp: int = 1
@export_group("Provisional Bite")
@export var approach_speed: float = 170.0
@export var approach_timeout: float = 3.0
@export var bite_windup: float = 0.75
@export var bite_active: float = 0.22
@export var bite_recovery: float = 0.55
@export var bite_reach: float = 180.0
@export_group("Provisional Owner Sequence")
@export var bark_windup: float = 0.8
@export var owner_entry_duration: float = 1.1
@export var owner_warning: float = 0.7
@export var owner_swing_duration: float = 0.26
@export var owner_active: float = 0.18
@export var owner_gap: float = 0.18
@export var owner_recovery: float = 0.8
@export var owner_strike_width: float = 96.0
@export var owner_target_min_x: float = 240.0
@export var owner_target_max_x: float = 1040.0
@export var owner_target_spacing: float = 180.0
@export var owner_rise_from := Vector2(640, 1600)
@export var owner_rise_to := Vector2(640, 720)
@export var owner_random_seed: int = 0

var state: State = State.INTRO
var state_time: float = 0.0
var hp: int
var phase: int = 1
var direction: float = -1.0
var charge_count: int = 0
var impact_count: int = 0
var player_hit_count: int = 0
var bite_count: int = 0
var bark_count: int = 0
var owner_strikes: int = 0
var _strike_index: int = 0
var _strike_x: float = 0.0
var _sequence_points: Array[float] = []
var _locked_owner_rect := Rect2()
var _owner_rng := RandomNumberGenerator.new()
var _arm_from := Vector2.ZERO
var _attack_serial: int = 0
var _attack_rect := Rect2()
var _warning_rect := Rect2()
var _locked_bite_rect := Rect2()
var _attack_hit := false
var _impact_latched := false
var _hurt_grace: float = 0.0
var _transition_pending := false
var _entry_run: Dictionary = {}

@onready var run_state: RunState = $RunState
@onready var player: Player = $World/Arena/Player
@onready var dog: CharacterBody2D = $World/Arena/Dog
@onready var dog_visual: Node2D = $World/Arena/Dog/Visual
@onready var arrow: Line2D = $World/Arena/Dog/AimArrow
@onready var attack_visual: Polygon2D = $World/Arena/AttackZone
@onready var boss_label: Label = $HUD/BossLabel
@onready var health_bar: ProgressBar = $HUD/BossHealth
@onready var health_value: Label = $HUD/HealthValue
@onready var lives_label: Label = $HUD/LivesLabel
@onready var cue_label: Label = $HUD/CueLabel
@onready var pause_panel: Panel = $HUD/PausePanel
@onready var result_panel: Panel = $HUD/ResultPanel
@onready var dog_owner: Node2D = $World/Arena/Owner
@onready var stick: Polygon2D = $World/Arena/Stick
@onready var owner_targets: Node2D = $World/Arena/OwnerTargets
@onready var bark_cue: Line2D = $World/Arena/Dog/BarkCue
@onready var owner_arm: Line2D = $World/Arena/Owner/SwingArm
@onready var owner_hand: Polygon2D = $World/Arena/Owner/Hand


func _ready() -> void:
	hp = maximum_hp
	dog.add_collision_exception_with(player)
	player.add_collision_exception_with(dog)
	run_state.reset_run()
	if has_meta("carried_run"):
		_entry_run = get_meta("carried_run").duplicate(true)
		run_state.max_energy = int(_entry_run["max_energy"])
		run_state.starting_lives = int(_entry_run["starting_lives"])
		run_state.energy = int(_entry_run["energy"])
		run_state.lives = int(_entry_run["lives"])
		run_state.current_floor = int(_entry_run["current_floor"])
		run_state.highest_floor = int(_entry_run["highest_floor"])
		run_state.elapsed_seconds = float(_entry_run["elapsed_seconds"])
		$HUD/DevelopmentLabel.text = "Level 1 / Dog boss"
	run_state.game_over.connect(_on_player_death)
	$HUD/PauseButton.pressed.connect(_toggle_pause)
	$HUD/PausePanel/Resume.pressed.connect(_toggle_pause)
	$HUD/PausePanel/Retry.pressed.connect(_retry)
	$HUD/PausePanel/Exit.pressed.connect(_exit)
	$HUD/ResultPanel/Retry.pressed.connect(_retry)
	$HUD/ResultPanel/Exit.pressed.connect(_exit)
	health_bar.max_value = maximum_hp
	var pole_half_width := owner_strike_width * 0.5
	stick.polygon = PackedVector2Array([Vector2(-pole_half_width, 0), Vector2(pole_half_width, 0), Vector2(pole_half_width, 500), Vector2(-pole_half_width, 500)])
	if owner_random_seed == 0:
		_owner_rng.randomize()
	else:
		_owner_rng.seed = owner_random_seed
	_set_state(State.INTRO)
	if not (0 < phase_three_hp and phase_three_hp < phase_two_hp and phase_two_hp < maximum_hp) or not _valid_owner_targets():
		push_error("Dog boss needs ordered HP thresholds and room for three separated random strikes.")
		set_physics_process(false)
		player.process_mode = Node.PROCESS_MODE_DISABLED
		cue_label.text = "INVALID GRAYBOX SETTINGS — CHECK INSPECTOR"
		return
	_log("ready", {"hp": hp, "lives": run_state.lives, "entry": "level_1" if not _entry_run.is_empty() else "development_scene"})


func _physics_process(delta: float) -> void:
	if get_tree().paused or state == State.FINISHED:
		return
	state_time += delta
	_hurt_grace = maxf(_hurt_grace - delta, 0.0)
	player.modulate.a = 0.5 if _hurt_grace > 0.0 and int(_hurt_grace * 12.0) % 2 == 0 else 1.0
	dog.velocity.x = direction * charge_speed if state == State.CHARGE else 0.0
	if state == State.BITE_APPROACH:
		direction = 1.0 if player.global_position.x >= dog.global_position.x else -1.0
		dog_visual.scale.x = direction
		dog.velocity.x = direction * approach_speed
	dog.velocity.y = minf(dog.velocity.y + 1450.0 * delta, 1050.0)
	dog.move_and_slide()
	match state:
		State.INTRO:
			if state_time >= 0.7:
				_begin_cycle()
		State.CHARGE_WINDUP:
			if state_time >= charge_windup:
				_set_state(State.CHARGE)
		State.CHARGE:
			_attack_rect = Rect2(dog.global_position - Vector2(55, 36), Vector2(110, 72))
			_try_hurt_player()
			if state == State.FINISHED:
				return
			for index in range(dog.get_slide_collision_count()):
				var collision := dog.get_slide_collision(index)
				var body := collision.get_collider() as Node
				if absf(collision.get_normal().x) > 0.5 and body != null and body.is_in_group("boss_obstacle"):
					_obstacle_impact()
					break
			if state == State.CHARGE and state_time >= charge_timeout:
				_log("charge_timeout")
				_set_state(State.RECOVER)
		State.IMPACT:
			if state_time >= impact_duration:
				_set_state(State.RECOVER)
		State.RECOVER:
			if state_time >= recovery_duration:
				_begin_cycle()
		State.BITE_APPROACH:
			if absf(player.global_position.x - dog.global_position.x) <= 180.0 or state_time >= approach_timeout:
				_lock_bite()
		State.BITE_WINDUP:
			if state_time >= bite_windup:
				_set_state(State.BITE_ACTIVE)
				_attack_rect = _locked_bite_rect
		State.BITE_ACTIVE:
			_try_hurt_player()
			if state != State.FINISHED and state_time >= bite_active:
				_set_state(State.BITE_RECOVER)
		State.BITE_RECOVER:
			if state_time >= bite_recovery:
				_begin_charge()
		State.BARK:
			if state_time >= bark_windup:
				_set_state(State.OWNER_ENTER)
				_prepare_owner_targets()
				dog_owner.position = owner_rise_from
				dog_owner.show()
		State.OWNER_ENTER:
			var progress := clampf(state_time / maxf(owner_entry_duration, 0.01), 0.0, 1.0)
			progress = progress * progress * (3.0 - 2.0 * progress)
			dog_owner.position = owner_rise_from.lerp(owner_rise_to, progress)
			if state_time >= owner_entry_duration:
				_strike_index = 0
				_sequence_points.clear()
				_begin_owner_strike()
		State.OWNER_WINDUP:
			_pose_owner_arm(_arm_from.lerp(Vector2(_strike_x, -110), clampf(state_time / 0.22, 0.0, 1.0)))
			if state_time >= owner_warning:
				_set_state(State.OWNER_ACTIVE)
				_update_owner_swing()
				owner_strikes += 1
				_log("owner_strike_active", {"sequence": bark_count, "strike": _strike_index + 1, "x": _strike_x})
		State.OWNER_ACTIVE:
			_update_owner_swing()
			_try_hurt_player()
			if state != State.FINISHED and state_time >= owner_swing_duration + owner_active:
				_log("owner_strike_finished", {"sequence": bark_count, "strike": _strike_index + 1})
				_set_state(State.OWNER_GAP)
		State.OWNER_GAP:
			if state_time >= owner_gap:
				_strike_index += 1
				if _strike_index < 3:
					_begin_owner_strike()
				else:
					_set_state(State.OWNER_RECOVER)
					_log("owner_sequence_complete", {"sequence": bark_count, "strikes": 3, "points": _sequence_points.duplicate()})
		State.OWNER_RECOVER:
			dog_owner.position = owner_rise_to.lerp(owner_rise_from, clampf(state_time / maxf(owner_recovery, 0.01), 0.0, 1.0))
			if state_time >= owner_recovery:
				dog_owner.hide()
				_begin_charge()
	_sync_ui()


func _begin_cycle() -> void:
	var next_phase := 3 if hp <= phase_three_hp else 2 if hp <= phase_two_hp else 1
	if phase != next_phase:
		phase = next_phase
		_log("phase_changed", {"hp": hp})
	if phase == 3:
		direction = 1.0 if player.global_position.x >= dog.global_position.x else -1.0
		dog_visual.scale.x = direction
		bark_cue.scale.x = -direction
		bark_count += 1
		_set_state(State.BARK)
		_log("bark_begin", {"sequence": bark_count})
	elif phase == 2:
		_set_state(State.BITE_APPROACH)
	else:
		_begin_charge()


func _begin_charge() -> void:
	direction = 1.0 if player.global_position.x >= dog.global_position.x else -1.0
	dog_visual.scale.x = direction
	arrow.points = PackedVector2Array([Vector2.ZERO, Vector2(direction * 105.0, 0)])
	charge_count += 1
	_attack_serial += 1
	_impact_latched = false
	_set_state(State.CHARGE_WINDUP)
	_log("charge_begin", {"charge": charge_count, "direction": direction})


func _lock_bite() -> void:
	_set_state(State.BITE_WINDUP)
	bite_count += 1
	_attack_serial += 1
	dog.velocity.x = 0.0
	var left := dog.global_position.x + 55.0 if direction > 0.0 else dog.global_position.x - 55.0 - bite_reach
	_locked_bite_rect = Rect2(Vector2(left, dog.global_position.y - 54.0), Vector2(bite_reach, 90.0))
	_warning_rect = _locked_bite_rect
	_log("bite_locked", {"bite": bite_count, "x": left, "width": bite_reach, "direction": direction})


func _valid_owner_targets() -> bool:
	return owner_targets.get_child_count() == 3 and owner_target_spacing >= owner_strike_width * 1.5 and owner_target_max_x - owner_target_min_x >= owner_target_spacing * 2.0


func _prepare_owner_targets() -> void:
	# Three random, separated x positions, shuffled to avoid a fixed left/right order.
	var free_span := owner_target_max_x - owner_target_min_x - owner_target_spacing * 2.0
	var offsets: Array[float] = []
	for index in range(3):
		offsets.append(_owner_rng.randf_range(0.0, free_span))
	offsets.sort()
	var points: Array[float] = []
	for index in range(3):
		points.append(owner_target_min_x + offsets[index] + owner_target_spacing * index)
	for index in range(2, 0, -1):
		var other := _owner_rng.randi_range(0, index)
		var previous := points[index]
		points[index] = points[other]
		points[other] = previous
	for index in range(3):
		(owner_targets.get_child(index) as Node2D).position.x = points[index]
	_log("random_owner_targets", {"points": points.duplicate(), "seed": _owner_rng.seed})


func _pose_owner_arm(grip: Vector2) -> void:
	dog_owner.call("pose_grip", grip)


func _update_owner_swing() -> void:
	var progress := clampf(state_time / maxf(owner_swing_duration, 0.01), 0.0, 1.0)
	var tip_y := lerpf(-40.0, 620.0, progress * progress)
	stick.position = Vector2(_strike_x, tip_y - 500.0)
	_pose_owner_arm(Vector2(_strike_x, tip_y - 70.0))
	var top := maxf(stick.position.y, 0.0)
	_attack_rect = Rect2(Vector2(_strike_x - owner_strike_width * 0.5, top), Vector2(owner_strike_width, maxf(tip_y - top, 0.0)))


func _begin_owner_strike() -> void:
	_set_state(State.OWNER_WINDUP)
	_attack_serial += 1
	_strike_x = (owner_targets.get_child(_strike_index) as Node2D).global_position.x
	_sequence_points.append(_strike_x)
	_locked_owner_rect = Rect2(Vector2(_strike_x - owner_strike_width * 0.5, 0), Vector2(owner_strike_width, 620))
	_warning_rect = _locked_owner_rect
	stick.position = Vector2(_strike_x, -540)
	_arm_from = dog_owner.to_global(owner_hand.position)
	_log("owner_strike_warning", {"sequence": bark_count, "strike": _strike_index + 1, "x": _strike_x})


func _obstacle_impact() -> void:
	if state != State.CHARGE or _impact_latched:
		return
	_impact_latched = true
	impact_count += 1
	hp = maxi(hp - 1, 0)
	dog.velocity.x = 0.0
	_log("charge_impact", {"charge": charge_count, "hp": hp, "impact_count": impact_count})
	if hp == 0:
		_finish(true)
	else:
		_set_state(State.IMPACT)


func _try_hurt_player() -> void:
	if _attack_hit or _hurt_grace > 0.0 or state not in [State.CHARGE, State.BITE_ACTIVE, State.OWNER_ACTIVE]:
		return
	var shape := player.get_node("CollisionShape2D") as CollisionShape2D
	var size := (shape.shape as RectangleShape2D).size * shape.global_scale.abs()
	var bounds := Rect2(shape.global_position - size * 0.5, size)
	if not _attack_rect.has_area() or not _attack_rect.intersects(bounds):
		return
	_attack_hit = true
	_hurt_grace = hit_grace
	player_hit_count += 1
	_log("player_hit", {"state": State.keys()[state], "attack": _attack_serial, "cost": player_hit_cost})
	for hit in range(player_hit_cost):
		if run_state.lives > 0:
			run_state.lose_life()


func _set_state(next: State) -> void:
	state = next
	state_time = 0.0
	_attack_rect = Rect2()
	_warning_rect = Rect2()
	_attack_hit = false
	arrow.visible = state == State.CHARGE_WINDUP
	bark_cue.visible = state == State.BARK
	stick.visible = state == State.OWNER_ACTIVE
	dog_visual.modulate = Color("cfb47c") if state == State.CHARGE_WINDUP else Color("b47a69") if state == State.CHARGE else Color("9eafa3") if state == State.IMPACT else Color.WHITE
	_sync_ui()


func _sync_ui() -> void:
	boss_label.text = "Dog  /  phase %d" % phase
	health_bar.value = hp
	health_value.text = "%d / %d" % [hp, maximum_hp]
	lives_label.text = "Lives %d     Energy %d" % [run_state.lives, run_state.energy]
	var messages := {State.INTRO: "A / D move    Space jump    Esc pause", State.CHARGE_WINDUP: "Charge — jump over the dog", State.CHARGE: "Jump!", State.IMPACT: "Crash! Dog takes damage", State.RECOVER: "Dog recovers", State.BITE_APPROACH: "Dog approaches", State.BITE_WINDUP: "Bite — move out of the marked reach", State.BITE_ACTIVE: "Bite!", State.BITE_RECOVER: "Dog recovers", State.BARK: "Bark! The owner is coming", State.OWNER_ENTER: "Watch the three target points", State.OWNER_WINDUP: "Stick %d / 3 — leave the marked column" % (_strike_index + 1), State.OWNER_ACTIVE: "Stick %d / 3!" % (_strike_index + 1), State.OWNER_GAP: "Next target", State.OWNER_RECOVER: "Three strikes complete", State.FINISHED: ""}
	cue_label.text = messages.get(state, "")
	var displayed_rect := _attack_rect if _attack_rect.has_area() else _warning_rect
	attack_visual.color = Color(0.64, 0.32, 0.26, 0.15) if _attack_rect.has_area() else Color(0.69, 0.54, 0.31, 0.12)
	attack_visual.visible = displayed_rect.has_area() and state != State.FINISHED
	if attack_visual.visible:
		var corner := displayed_rect.position
		var size := displayed_rect.size
		attack_visual.polygon = PackedVector2Array([corner, corner + Vector2(size.x, 0), corner + size, corner + Vector2(0, size.y)])


func _on_player_death() -> void:
	_finish(false)


func _finish(victory: bool) -> void:
	if state == State.FINISHED:
		return
	_set_state(State.FINISHED)
	dog.velocity = Vector2.ZERO
	player.process_mode = Node.PROCESS_MODE_DISABLED
	player.modulate.a = 1.0
	dog_owner.hide()
	run_state.stop_timer()
	get_tree().paused = false
	pause_panel.hide()
	result_panel.show()
	$HUD/ResultPanel/Title.text = "Dog defeated" if victory else "Game over"
	$HUD/ResultPanel/Retry.grab_focus()
	_log("result", {"victory": victory, "hp": hp, "lives": run_state.lives})
	encounter_finished.emit(victory)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		_toggle_pause()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_node_ready() and state != State.FINISHED:
		call_deferred("_pause_on_focus_loss")


func _pause_on_focus_loss() -> void:
	if is_inside_tree() and state != State.FINISHED:
		get_tree().paused = true
		pause_panel.show()


func _toggle_pause() -> void:
	if state == State.FINISHED:
		return
	get_tree().paused = not get_tree().paused
	pause_panel.visible = get_tree().paused
	if get_tree().paused:
		$HUD/PausePanel/Resume.grab_focus()
	else:
		get_viewport().gui_release_focus()


func _retry() -> void:
	if _transition_pending:
		return
	_transition_pending = true
	get_tree().paused = false
	if _entry_run.is_empty():
		get_tree().reload_current_scene()
		return
	set_physics_process(false)
	player.process_mode = Node.PROCESS_MODE_DISABLED
	run_state.stop_timer()
	call_deferred("_restart_with_entry_run")


func _restart_with_entry_run() -> void:
	var scene := load(scene_file_path) as PackedScene
	if scene == null:
		push_error("Dog boss retry could not load its scene.")
		return
	var replacement := scene.instantiate()
	replacement.set_meta("carried_run", _entry_run.duplicate(true))
	var tree := get_tree()
	tree.root.add_child(replacement)
	tree.current_scene = replacement
	queue_free()


func _exit() -> void:
	if _transition_pending:
		return
	_transition_pending = true
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")


func _log(event: String, details: Dictionary = {}) -> void:
	details["event"] = event
	details["ms"] = Time.get_ticks_msec()
	details["phase"] = phase
	details["encounter"] = get_instance_id()
	print("DOG_BOSS ", JSON.stringify(details))

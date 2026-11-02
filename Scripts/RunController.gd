class_name RunController
extends Node2D

signal game_over_requested

enum RunMode { CLIMB, FIGHT, TERMINAL }

const ENERGY_ENCOUNTER_REASON := 0
const BIRD_ENCOUNTER_REASON := 1
const ENERGY_DEFEAT_ENERGY := 50
const ENERGY_VICTORY_ENERGY := 100

@export var fight_scene: PackedScene = preload("res://Scenes/UI/Fight.tscn")
@export var victory_scene: PackedScene = preload("res://Scenes/UI/Victory.tscn")
@export var game_over_scene: PackedScene = preload("res://Scenes/UI/GameOver.tscn")
@export var boss_scene: PackedScene = preload("res://Scenes/Boss/DogBoss.tscn")

var run_mode: RunMode = RunMode.CLIMB
var active_encounter_reason: StringName = &""

@onready var run_state: RunState = $RunState
@onready var climb_level: ClimbLevel = $World/ClimbLevel
@onready var fight_layer: CanvasLayer = $FightLayer
@onready var fight_placeholder: Control = $FightLayer/Fight
@onready var outcome_layer: CanvasLayer = $OutcomeLayer
@onready var hud: HUD = $HUDLayer/HUD
@onready var run_music: AudioStreamPlayer = $RunMusic

var _active_fight: FightController
var _encounter_transition_pending := false
var _fight_result_resolved := false
var _game_over_transition_started := false
var _boss_transition_started := false


func _ready() -> void:
	run_mode = RunMode.CLIMB
	active_encounter_reason = &""
	_encounter_transition_pending = false
	_fight_result_resolved = false
	_game_over_transition_started = false
	_boss_transition_started = false
	run_state.reset_run()
	run_state.energy_depleted.connect(_on_energy_depleted)
	run_state.game_over.connect(_on_run_state_game_over)
	climb_level.bird_encounter_requested.connect(_on_bird_encounter_requested)
	climb_level.victory_requested.connect(_on_victory_requested)
	fight_layer.hide()
	fight_placeholder.hide()
	var climb_track := run_music.stream as AudioStreamMP3
	if climb_track != null:
		climb_track.loop = true
	run_music.play()


func _on_energy_depleted() -> void:
	if run_state.energy != 0:
		return

	if run_mode == RunMode.CLIMB:
		_begin_encounter(&"energy")
	elif run_mode == RunMode.FIGHT and _encounter_transition_pending:
		# Energy depletion wins if it arrives during the same-frame Bird transition.
		active_encounter_reason = &"energy"


func _on_bird_encounter_requested() -> void:
	if run_mode == RunMode.CLIMB:
		var reason: StringName = &"energy" if run_state.energy == 0 else &"bird"
		_begin_encounter(reason)
	elif run_mode == RunMode.FIGHT and _encounter_transition_pending and run_state.energy == 0:
		active_encounter_reason = &"energy"


func _on_victory_requested() -> void:
	if _boss_transition_started or run_mode != RunMode.CLIMB or get_tree().paused or run_state.lives <= 0:
		return
	if boss_scene == null:
		push_error("RunController cannot enter the dog boss: Boss Scene is not assigned.")
		return
	_boss_transition_started = true
	var carried_run := {
		"max_energy": run_state.max_energy,
		"starting_lives": run_state.starting_lives,
		"energy": run_state.energy,
		"lives": run_state.lives,
		"current_floor": run_state.current_floor,
		"highest_floor": run_state.highest_floor,
		"elapsed_seconds": run_state.elapsed_seconds,
	}
	run_mode = RunMode.TERMINAL
	active_encounter_reason = &""
	_encounter_transition_pending = false
	run_state.stop_timer()
	run_music.stop()
	climb_level.freeze_for_fight()
	climb_level.bird_spawner.stop_at_floor_49()
	hud.set_pause_available(false)
	call_deferred("_enter_boss", carried_run)


func _enter_boss(carried_run: Dictionary) -> void:
	if not is_inside_tree() or not _boss_transition_started:
		return
	var boss := boss_scene.instantiate()
	boss.set_meta("carried_run", carried_run.duplicate(true))
	var tree := get_tree()
	tree.root.add_child(boss)
	tree.current_scene = boss
	queue_free()


func _begin_encounter(reason: StringName) -> void:
	if run_mode != RunMode.CLIMB:
		return

	# Lock synchronously; defer only the scene/UI transition out of physics callbacks.
	run_mode = RunMode.FIGHT
	active_encounter_reason = &"energy" if run_state.energy == 0 else reason
	_encounter_transition_pending = true
	_fight_result_resolved = false
	call_deferred("_show_fight")


func _show_fight() -> void:
	if run_mode != RunMode.FIGHT or not _encounter_transition_pending:
		return
	_encounter_transition_pending = false
	run_music.stream_paused = true
	climb_level.freeze_for_fight()
	climb_level.capture_fight_state()

	if fight_scene == null:
		push_error("RunController cannot start a Fight: Fight Scene is not assigned.")
		_abort_fight_transition()
		return

	var fight_node := fight_scene.instantiate()
	var fight := fight_node as FightController
	if fight == null:
		if fight_node != null:
			fight_node.free()
		push_error("RunController could not create a FightController from Fight Scene.")
		_abort_fight_transition()
		return

	# Configure and connect before entering the tree so _ready sees the right reason.
	var fight_reason := ENERGY_ENCOUNTER_REASON if active_encounter_reason == &"energy" else BIRD_ENCOUNTER_REASON
	fight.configure_encounter(fight_reason)
	fight.name = "ActiveFight"
	fight.fight_finished.connect(_on_fight_finished)
	_active_fight = fight
	fight_layer.show()
	fight_layer.add_child(fight)


func _on_fight_finished(result: FightController.FightResult) -> void:
	if run_mode != RunMode.FIGHT or (active_encounter_reason != &"energy" and active_encounter_reason != &"bird"):
		return
	if _fight_result_resolved:
		return
	if result != FightController.FightResult.VICTORY and result != FightController.FightResult.DEFEAT and result != FightController.FightResult.RETREAT:
		push_error("RunController ignored an unknown Fight result.")
		return
	_fight_result_resolved = true

	fight_layer.hide()
	if _active_fight != null:
		_active_fight.queue_free()
		_active_fight = null

	if result == FightController.FightResult.VICTORY:
		if active_encounter_reason == &"energy":
			run_state.energy = ENERGY_VICTORY_ENERGY
		climb_level.resume_from_fight()
	elif active_encounter_reason == &"energy":
		run_state.energy = ENERGY_DEFEAT_ENERGY
		climb_level.respawn_after_fight_defeat()
	else:
		run_state.lose_life()
		if run_state.lives == 0:
			return
		climb_level.respawn_after_fight_defeat()

	active_encounter_reason = &""
	run_mode = RunMode.CLIMB
	run_music.stream_paused = false


func _abort_fight_transition() -> void:
	fight_layer.hide()
	if _active_fight != null:
		_active_fight.queue_free()
		_active_fight = null
	climb_level.resume_from_fight()
	active_encounter_reason = &""
	_encounter_transition_pending = false
	run_mode = RunMode.CLIMB
	run_music.stream_paused = false


func _on_run_state_game_over() -> void:
	if _game_over_transition_started or run_state.lives != 0:
		return
	if run_mode != RunMode.FIGHT or active_encounter_reason != &"bird":
		return
	_game_over_transition_started = true

	var game_over: GameOver
	if game_over_scene == null:
		push_error("RunController cannot show Game Over: Game Over Scene is not assigned.")
	else:
		var game_over_node := game_over_scene.instantiate()
		game_over = game_over_node as GameOver
		if game_over == null:
			if game_over_node != null:
				game_over_node.free()
			push_error("RunController could not create a GameOver scene.")

	# Capture the summary before stopping the timer or changing the visible Run layers.
	var final_time := run_state.elapsed_seconds
	var highest_floor := run_state.highest_floor
	run_mode = RunMode.TERMINAL
	active_encounter_reason = &""
	_encounter_transition_pending = false
	run_state.stop_timer()
	run_music.stop()
	climb_level.bird_spawner.stop_at_floor_49()
	climb_level.process_mode = Node.PROCESS_MODE_DISABLED
	hud.set_pause_available(false)
	if game_over != null:
		game_over.configure_result(final_time, highest_floor, run_state.lives)
		game_over.name = "GameOver"
		outcome_layer.add_child(game_over)
	game_over_requested.emit()

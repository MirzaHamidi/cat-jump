class_name ClimbLevel
extends Node2D

signal victory_requested
signal bird_encounter_requested

@export var run_state_path: NodePath = NodePath("../../RunState")
@export_node_path("Area2D") var rooftop_goal_path: NodePath = NodePath("Traversal/Floors_41_50/Floor_050/Traversal/RooftopGoal")
@export_node_path("FloorTier") var victory_floor_path: NodePath = NodePath("Traversal/Floors_41_50/Floor_050")

@onready var player: CharacterBody2D = $Player
@onready var run_state: RunState = get_node_or_null(run_state_path) as RunState
@onready var camera: ClimbingCamera = $Camera2D
@onready var bird_spawner: BirdSpawner = $Hazards/BirdSpawner
@onready var rooftop_goal: Area2D = get_node_or_null(rooftop_goal_path) as Area2D
@onready var victory_floor: FloorTier = get_node_or_null(victory_floor_path) as FloorTier
@onready var rooftop_deck: StaticBody2D = victory_floor.get_node_or_null("Traversal/RooftopDeck") as StaticBody2D if victory_floor else null

var bird_contact_grace_remaining: float = 0.0

var _rooftop_goal_request_sent := false
var _frozen_for_fight := false
var _fight_state_captured := false
var _previous_process_mode: int = Node.PROCESS_MODE_INHERIT
var _saved_player_position := Vector2.ZERO
var _saved_player_velocity := Vector2.ZERO
var _saved_coyote_timer := 0.0
var _saved_jump_buffer_timer := 0.0
var _saved_normal_jump_started := false
var _saved_double_jump_used := false
var _saved_camera_position := Vector2.ZERO
var _saved_camera_highest_y := 0.0


func _ready() -> void:
	player.landed_on_surface.connect(_on_player_landed_on_surface)
	bird_spawner.bird_hit_requested.connect(_on_bird_hit_requested)
	var starting_tier := get_node_or_null("Traversal/Floors_01_10/Floor_001") as FloorTier
	if starting_tier and run_state:
		run_state.set_floor_progress(starting_tier.floor_number)
	if rooftop_goal:
		rooftop_goal.body_entered.connect(_on_rooftop_goal_body_entered)
	else:
		push_error("ClimbLevel needs its Rooftop Goal assigned in the Inspector.")
	if victory_floor == null:
		push_error("ClimbLevel needs its Victory Floor assigned in the Inspector.")


func _process(delta: float) -> void:
	if bird_contact_grace_remaining > 0.0:
		bird_contact_grace_remaining = maxf(bird_contact_grace_remaining - delta, 0.0)
	if rooftop_goal != null and rooftop_goal.get_overlapping_bodies().has(player):
		_request_rooftop_victory_if_ready()


func _on_player_landed_on_surface(collider: Object) -> void:
	var surface := collider as Node
	var landed_node := surface
	while landed_node != null:
		if landed_node is FloorTier:
			var floor_tier := landed_node as FloorTier
			var is_window := surface.scene_file_path == "res://Scenes/Gameplay/StandardWindow.tscn"
			var is_start := floor_tier.floor_number == 1 and surface.name == &"StartPlatform"
			var is_roof := floor_tier == victory_floor and surface == rooftop_deck
			if not (is_window or is_start or is_roof):
				var is_intermediate := surface.scene_file_path in [
					"res://Scenes/Assets/Environment/ACUnit.tscn",
					"res://Scenes/Assets/Environment/Balcony.tscn",
					"res://Scenes/Assets/Environment/FireEscapePlatform.tscn",
				]
				var previous_floor := maxi(floor_tier.floor_number - 1, 1)
				if is_intermediate and run_state and run_state.current_floor > previous_floor:
					run_state.set_floor_progress(previous_floor)
				return
			if run_state:
				run_state.set_floor_progress(floor_tier.floor_number)
			if floor_tier.floor_number >= 16 and floor_tier.floor_number < 49:
				bird_spawner.start_after_floor_16()
			if floor_tier.floor_number >= 49:
				bird_spawner.stop_at_floor_49()
			return
		landed_node = landed_node.get_parent()


func _on_bird_hit_requested() -> void:
	if is_bird_contact_grace_active():
		return
	bird_encounter_requested.emit()


func _on_rooftop_goal_body_entered(body: Node2D) -> void:
	if body != player:
		return
	_request_rooftop_victory_if_ready()


func _request_rooftop_victory_if_ready() -> void:
	if _rooftop_goal_request_sent or run_state == null or victory_floor == null:
		return
	if run_state.current_floor < victory_floor.floor_number:
		return
	if rooftop_goal == null or not rooftop_goal.get_overlapping_bodies().has(player):
		return
	if not _is_player_on_rooftop_deck():
		return
	_rooftop_goal_request_sent = true
	victory_requested.emit()


func _is_player_on_rooftop_deck() -> bool:
	if rooftop_deck == null or not player.is_on_floor():
		return false
	for i in range(player.get_slide_collision_count()):
		var collision := player.get_slide_collision(i)
		if collision.get_collider() == rooftop_deck and collision.get_normal().dot(Vector2.UP) > 0.7:
			return true
	return false


func stop_for_victory() -> void:
	bird_spawner.stop_at_floor_49()
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)


func freeze_for_fight() -> void:
	if _frozen_for_fight:
		return
	_previous_process_mode = process_mode
	_frozen_for_fight = true
	bird_spawner.cancel_for_encounter()
	process_mode = Node.PROCESS_MODE_DISABLED


func capture_fight_state() -> void:
	if not _frozen_for_fight:
		return
	_saved_player_position = player.global_position
	_saved_player_velocity = player.velocity
	_saved_coyote_timer = float(player.get("coyote_timer"))
	_saved_jump_buffer_timer = float(player.get("jump_buffer_timer"))
	_saved_normal_jump_started = bool(player.get("normal_jump_started"))
	_saved_double_jump_used = bool(player.get("double_jump_used"))
	_saved_camera_position = camera.global_position
	_saved_camera_highest_y = camera.highest_camera_y
	_fight_state_captured = true


func resume_from_fight() -> void:
	if not _frozen_for_fight:
		return
	if _fight_state_captured:
		player.global_position = _saved_player_position
		player.velocity = _saved_player_velocity
		player.set("coyote_timer", _saved_coyote_timer)
		player.set("jump_buffer_timer", _saved_jump_buffer_timer)
		player.set("normal_jump_started", _saved_normal_jump_started)
		player.set("double_jump_used", _saved_double_jump_used)
		camera.global_position = _saved_camera_position
		camera.highest_camera_y = _saved_camera_highest_y
	_resume_climb_processing()


func respawn_after_energy_defeat() -> int:
	return respawn_after_fight_defeat()


func respawn_after_fight_defeat() -> int:
	if run_state == null:
		push_error("ClimbLevel cannot respawn after a Fight without RunState.")
		resume_from_fight()
		return 0

	var target_floor := maxi(run_state.current_floor - 5, 1)
	var anchor := _find_respawn_anchor(target_floor)
	if anchor == null:
		push_error("ClimbLevel has no RespawnAnchor for Fight target floor %d." % target_floor)
		resume_from_fight()
		return 0

	player.clear_pipe_state()
	player.global_position = anchor.global_position
	player.velocity = Vector2.ZERO
	player.set("coyote_timer", 0.0)
	player.set("jump_buffer_timer", 0.0)
	player.set("normal_jump_started", false)
	player.set("double_jump_used", false)
	run_state.set_floor_progress(target_floor)
	camera.snap_to_target()
	grant_bird_contact_grace()
	_resume_climb_processing()
	return target_floor


func grant_bird_contact_grace() -> void:
	bird_contact_grace_remaining = 1.0


func is_bird_contact_grace_active() -> bool:
	return bird_contact_grace_remaining > 0.0


func _find_respawn_anchor(floor_number: int) -> Marker2D:
	var traversal := get_node_or_null("Traversal")
	if traversal == null:
		return null
	for section in traversal.get_children():
		for child in section.get_children():
			var tier := child as FloorTier
			if tier != null and tier.floor_number == floor_number:
				return tier.get_node_or_null("RespawnAnchor") as Marker2D
	return null


func _resume_climb_processing() -> void:
	if not _frozen_for_fight:
		return
	process_mode = _previous_process_mode
	_frozen_for_fight = false
	_fight_state_captured = false
	bird_spawner.resume_after_encounter()

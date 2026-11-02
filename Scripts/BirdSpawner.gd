class_name BirdSpawner
extends Node2D

signal bird_hit_requested
signal bird_passed

@export_group("Scene References")
@export var bird_scene: PackedScene
@export var player: CharacterBody2D
@export var camera: Camera2D
@export var lane_01: Marker2D
@export var lane_02: Marker2D
@export var lane_03: Marker2D
@export var lane_04: Marker2D

@export_group("Bird Timing")
@export_range(0.0, 120.0, 0.1) var initial_warmup: float = 25.0
@export_range(0.1, 10.0, 0.1) var warning_duration: float = 1.5
@export_range(0.0, 120.0, 0.1) var interval_min: float = 35.0
@export_range(0.0, 120.0, 0.1) var interval_max: float = 45.0
@export_range(1.0, 2000.0, 1.0) var bird_speed: float = 600.0
@export_range(0.0, 500.0, 1.0) var spawn_height: float = 80.0

@onready var timer: Timer = $Timer
@onready var warning_cue_layer: CanvasLayer = $WarningCueLayer
@onready var warning_cue: Control = $WarningCueLayer/WarningCue
@onready var warning_label: Label = $WarningCueLayer/WarningCue/WarningPanel/WarningLabel
@onready var warning_hint: Label = $WarningCueLayer/WarningCue/WarningPanel/WarningHint
@onready var lane_highlight: ColorRect = $WarningCueLayer/WarningCue/LaneHighlight

var run_active := false
var warning_active := false
var selected_lane_index := -1
var active_bird: Bird

var _next_lane_index := 0
var _paused_for_encounter := false
var _stopped_at_floor_49 := false
var _warning_flash_time := 0.0
var _random := RandomNumberGenerator.new()


func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	_random.randomize()
	_hide_warning()


func _process(delta: float) -> void:
	if not warning_active:
		return

	_warning_flash_time += delta
	_update_warning_display()
	warning_cue.modulate.a = 0.68 + 0.32 * absf(sin(_warning_flash_time * TAU * 2.5))


func start_after_floor_16() -> void:
	if run_active or _stopped_at_floor_49:
		return
	if not _has_required_references():
		return

	run_active = true
	_paused_for_encounter = false
	timer.start(maxf(initial_warmup, 0.01))


func cancel_for_encounter() -> void:
	if _stopped_at_floor_49:
		return

	_paused_for_encounter = run_active
	timer.stop()
	warning_active = false
	_hide_warning()
	_clear_active_bird()


func resume_after_encounter() -> void:
	if not _paused_for_encounter or not run_active or _stopped_at_floor_49:
		return

	_paused_for_encounter = false
	_schedule_next_warning()


func stop_at_floor_49() -> void:
	_stopped_at_floor_49 = true
	run_active = false
	_paused_for_encounter = false
	timer.stop()
	warning_active = false
	_hide_warning()
	_clear_active_bird()


func _has_required_references() -> bool:
	var lanes: Array[Marker2D] = [lane_01, lane_02, lane_03, lane_04]
	if bird_scene == null:
		push_error("BirdSpawner needs a Bird PackedScene assigned in the Inspector.")
		return false
	if player == null or camera == null:
		push_error("BirdSpawner needs its Player and Camera references assigned in the Inspector.")
		return false
	for index in range(lanes.size()):
		if lanes[index] == null:
			push_error("BirdSpawner Lane_%02d is not assigned in the Inspector." % (index + 1))
			return false
	return true


func _on_timer_timeout() -> void:
	if not run_active or _paused_for_encounter or _stopped_at_floor_49 or active_bird != null:
		return

	if warning_active:
		_spawn_bird()
	else:
		_begin_warning()


func _begin_warning() -> void:
	if selected_lane_index < 0:
		selected_lane_index = _next_lane_index
	_warning_flash_time = 0.0
	warning_active = true
	_update_warning_display()
	warning_cue_layer.show()
	timer.start(maxf(warning_duration, 0.01))


func _spawn_bird() -> void:
	var lanes: Array[Marker2D] = [lane_01, lane_02, lane_03, lane_04]
	if selected_lane_index < 0 or selected_lane_index >= lanes.size():
		warning_active = false
		_hide_warning()
		_schedule_next_warning()
		return

	var bird_node := bird_scene.instantiate()
	var bird := bird_node as Bird
	if bird == null:
		if bird_node != null:
			bird_node.free()
		push_error("BirdSpawner could not create a Bird from its PackedScene.")
		warning_active = false
		_hide_warning()
		_schedule_next_warning()
		return

	var lane := lanes[selected_lane_index]
	warning_active = false
	_hide_warning()
	_next_lane_index = (_next_lane_index + 1) % lanes.size()
	selected_lane_index = -1

	active_bird = bird
	bird.name = "ActiveBird"
	bird.speed = bird_speed
	bird.target_player = player
	bird.camera = camera
	bird.hit_requested.connect(_on_bird_hit_requested)
	bird.passed.connect(_on_bird_passed)
	add_child(bird)
	var visible_height := camera.get_viewport_rect().size.y / maxf(camera.zoom.y, 0.001)
	var screen_top := camera.get_screen_center_position().y - visible_height * 0.5
	bird.global_position = Vector2(lane.global_position.x, screen_top - spawn_height)


func _on_bird_hit_requested(bird: Bird) -> void:
	if bird != active_bird:
		return

	active_bird = null
	bird_hit_requested.emit()
	_schedule_next_warning()


func _on_bird_passed(bird: Bird) -> void:
	if bird != active_bird:
		return

	active_bird = null
	bird_passed.emit()
	_schedule_next_warning()


func _schedule_next_warning() -> void:
	warning_active = false
	_hide_warning()
	if not run_active or _paused_for_encounter or _stopped_at_floor_49:
		return

	var lower_bound := minf(interval_min, interval_max)
	var upper_bound := maxf(interval_min, interval_max)
	timer.start(maxf(_random.randf_range(lower_bound, upper_bound), 0.01))


func _update_warning_display() -> void:
	var lanes: Array[Marker2D] = [lane_01, lane_02, lane_03, lane_04]
	var lane_number := selected_lane_index + 1
	warning_label.text = "BIRD APPROACH - LANE %02d" % lane_number

	var viewport_width := get_viewport().get_visible_rect().size.x
	var lane_screen_position: Vector2 = get_viewport().get_canvas_transform() * lanes[selected_lane_index].global_position
	var highlight_width := lane_highlight.size.x
	var clamped_x := clampf(lane_screen_position.x - highlight_width * 0.5, 12.0, maxf(viewport_width - highlight_width - 12.0, 12.0))
	lane_highlight.position.x = clamped_x
	if lane_screen_position.x < 0.0:
		warning_hint.text = "LANE OFFSCREEN - APPROACHING FROM THE LEFT"
	elif lane_screen_position.x > viewport_width:
		warning_hint.text = "LANE OFFSCREEN - APPROACHING FROM THE RIGHT"
	else:
		warning_hint.text = "MOVE OUT OF THE MARKED LANE"


func _hide_warning() -> void:
	warning_cue_layer.hide()
	warning_cue.modulate.a = 1.0


func _clear_active_bird() -> void:
	if is_instance_valid(active_bird):
		active_bird.queue_free()
	active_bird = null

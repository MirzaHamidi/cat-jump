class_name ClimbingCamera
extends Camera2D

@export var target: Node2D
@export_category("Framing")
@export var vertical_offset: float = -110.0
@export var camera_smoothing_speed: float = 7.0
@export var downward_follow_threshold: float = 260.0

@export_category("Dynamic Framing")
@export_range(0.0, 120.0, 1.0) var horizontal_lookahead: float = 32.0
@export_range(0.0, 60.0, 1.0) var upward_lookahead: float = 12.0
@export_range(1.0, 1200.0, 1.0) var horizontal_full_speed: float = 340.0
@export_range(1.0, 1200.0, 1.0) var upward_full_speed: float = 610.0
@export_range(0.1, 20.0, 0.1) var lookahead_smoothing_speed: float = 5.0

var highest_camera_y: float
var _horizontal_lookahead_offset := 0.0
var _upward_lookahead_offset := 0.0


func _ready() -> void:
	if target == null:
		push_warning("ClimbingCamera needs a target.")
		return

	snap_to_target()


func snap_to_target() -> void:
	_horizontal_lookahead_offset = 0.0
	_upward_lookahead_offset = 0.0
	if target == null:
		return
	global_position = target.global_position + Vector2(0.0, vertical_offset)
	highest_camera_y = global_position.y


func _physics_process(delta: float) -> void:
	if target == null:
		return

	var upward_target_y := target.global_position.y + vertical_offset
	var desired_y := highest_camera_y

	if upward_target_y < highest_camera_y:
		highest_camera_y = upward_target_y
		desired_y = upward_target_y
	elif target.global_position.y > highest_camera_y + downward_follow_threshold:
		desired_y = target.global_position.y - downward_follow_threshold
		highest_camera_y = desired_y

	# Keep the progress/descending threshold based on the original camera target;
	# the small velocity-based offsets affect only presentation.
	var motion_target := target as CharacterBody2D
	var desired_horizontal_offset := 0.0
	var desired_upward_offset := 0.0
	if motion_target != null:
		desired_horizontal_offset = clampf(motion_target.velocity.x / maxf(horizontal_full_speed, 0.001), -1.0, 1.0) * horizontal_lookahead
		desired_upward_offset = -clampf(-motion_target.velocity.y / maxf(upward_full_speed, 0.001), 0.0, 1.0) * upward_lookahead
	var lookahead_weight := 1.0 - exp(-lookahead_smoothing_speed * delta)
	_horizontal_lookahead_offset = lerpf(_horizontal_lookahead_offset, desired_horizontal_offset, lookahead_weight)
	_upward_lookahead_offset = lerpf(_upward_lookahead_offset, desired_upward_offset, lookahead_weight)

	var weight := 1.0 - exp(-camera_smoothing_speed * delta)
	global_position.x = lerpf(global_position.x, target.global_position.x + _horizontal_lookahead_offset, weight)
	global_position.y = lerpf(global_position.y, desired_y + _upward_lookahead_offset, weight)

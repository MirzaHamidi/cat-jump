extends Camera2D

@export var target: Node2D
@export_category("Framing")
@export var vertical_offset: float = -110.0
@export var camera_smoothing_speed: float = 7.0
@export var downward_follow_threshold: float = 260.0

var highest_camera_y: float


func _ready() -> void:
	if target == null:
		push_warning("ClimbingCamera needs a target.")
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

	var weight := 1.0 - exp(-camera_smoothing_speed * delta)
	global_position.x = lerpf(global_position.x, target.global_position.x, weight)
	global_position.y = lerpf(global_position.y, desired_y, weight)

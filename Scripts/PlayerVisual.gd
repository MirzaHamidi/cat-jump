extends AnimatedSprite2D
## Presentation only: reads Player after movement, without changing physics or input.

@export_range(1.0, 340.0, 1.0) var walk_to_run_speed: float = 220.0
@export_range(0.0, 10.0, 0.1) var breathing_delay: float = 1.5
@export_range(1.0, 30.0, 0.5) var sitting_delay: float = 6.0

@export_group("Landing Feedback")
@export_range(0.0, 0.5, 0.01) var landing_duration: float = 0.16
@export_range(0.0, 0.2, 0.01) var landing_squash: float = 0.08

# Source-pixel anchors keep the different sheet sizes on the same ground line.
# Running retains the artist's airborne strides around the shared baseline.
const FRAME_ANCHORS := {
	&"idle": Vector2(50, 81),
	&"breathing": Vector2(50, 81),
	&"walk": Vector2(56, 86),
	&"running": Vector2(56, 86),
	&"sit": Vector2(56, 86),
	&"sitting": Vector2(56, 85),
	&"standing": Vector2(56, 85),
}

var _facing: String = "east"
var _rest_time: float = 0.0
var _landing_time: float = 0.0

@onready var player: Player = get_parent() as Player
@onready var _base_scale: Vector2 = scale


func _ready() -> void:
	animation_finished.connect(_on_animation_finished)
	if not player.landed_on_surface.is_connected(_on_landed):
		player.landed_on_surface.connect(_on_landed)
	_play_clip(&"idle")


func _physics_process(delta: float) -> void:
	_update_landing_feedback(delta)
	if not is_zero_approx(player.velocity.x):
		_facing = "east" if player.velocity.x > 0.0 else "west"

	if player.active_pipe != null or not player.is_on_floor():
		_rest_time = 0.0
		# No jump/climb sheets were supplied. Hold an existing stride pose.
		var pose := 0 if player.velocity.y < 0.0 else 4
		_play_clip(&"running", pose)
		return

	if absf(player.velocity.x) > 1.0:
		_rest_time = 0.0
		if _is_clip("sitting") or (_is_clip("sit") and frame >= 5):
			_play_clip(&"standing")
		if _is_clip("standing") and is_playing():
			_play_clip(&"standing")
			# Rise quickly while movement responds, avoiding a long seated glide.
			speed_scale = 2.5
			return
		var gait: StringName = &"running" if absf(player.velocity.x) >= walk_to_run_speed else &"walk"
		_play_clip(gait)
		speed_scale = clampf(absf(player.velocity.x) / player.move_speed, 0.8, 1.15)
		return

	if _is_clip("standing") and is_playing():
		return
	_rest_time += delta
	if _rest_time >= sitting_delay:
		if not _is_clip("sit") and not _is_clip("sitting"):
			_play_clip(&"sit")
	elif _rest_time >= breathing_delay:
		_play_clip(&"breathing")
	else:
		_play_clip(&"idle")


func _on_landed(_collider: Object) -> void:
	_landing_time = maxf(landing_duration, 0.0)


func _update_landing_feedback(delta: float) -> void:
	if not player.is_on_floor() or player.active_pipe != null or landing_duration <= 0.0:
		_landing_time = 0.0
		scale = _base_scale
		return
	if _landing_time > 0.0:
		var amount := landing_squash * clampf(_landing_time / landing_duration, 0.0, 1.0)
		scale = _base_scale * Vector2(1.0 + amount, 1.0 - amount)
		_landing_time = maxf(_landing_time - delta, 0.0)
	else:
		scale = _base_scale


func _exit_tree() -> void:
	if is_node_ready():
		scale = _base_scale
	_landing_time = 0.0


func _play_clip(clip: StringName, held_frame: int = -1) -> void:
	var next_animation := StringName("%s_%s" % [clip, _facing])
	if animation != next_animation:
		var same_clip := _is_clip(String(clip))
		var previous_frame := frame
		var previous_progress := frame_progress
		play(next_animation)
		if same_clip:
			set_frame_and_progress(previous_frame, previous_progress)
	elif held_frame < 0 and not is_playing():
		play(next_animation)
	offset = -FRAME_ANCHORS[clip]
	speed_scale = 1.0
	if held_frame >= 0:
		set_frame_and_progress(held_frame, 0.0)
		pause()


func _is_clip(clip: String) -> bool:
	return String(animation).begins_with(clip + "_")


func _on_animation_finished() -> void:
	if _is_clip("sit"):
		_play_clip(&"sitting")
	elif _is_clip("standing"):
		_play_clip(&"idle")

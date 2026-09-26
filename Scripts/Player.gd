extends CharacterBody2D

@export_category("Horizontal Movement")
@export var move_speed: float = 340.0
@export var ground_acceleration: float = 2400.0
@export var ground_deceleration: float = 3000.0
@export var air_acceleration: float = 1650.0
@export var air_deceleration: float = 1000.0

@export_category("Jump")
@export var jump_velocity: float = -610.0
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12
@export_range(0.1, 1.0, 0.05) var jump_cut_multiplier: float = 0.45

@export_category("Gravity")
@export var gravity: float = 1450.0
@export var fall_gravity: float = 2300.0
@export var max_fall_speed: float = 1050.0

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0


func _physics_process(delta: float) -> void:
	var was_on_floor := is_on_floor()
	_update_jump_timers(delta, was_on_floor)
	_apply_horizontal_movement(delta, was_on_floor)
	_apply_gravity(delta)
	_try_jump()
	_apply_jump_cut()
	move_and_slide()


func _update_jump_timers(delta: float, was_on_floor: bool) -> void:
	if was_on_floor:
		coyote_timer = coyote_time
	else:
		coyote_timer = maxf(coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)


func _apply_horizontal_movement(delta: float, on_floor: bool) -> void:
	var input_direction := Input.get_axis("move_left", "move_right")
	var acceleration := ground_acceleration if on_floor else air_acceleration
	var deceleration := ground_deceleration if on_floor else air_deceleration

	if not is_zero_approx(input_direction):
		velocity.x = move_toward(velocity.x, input_direction * move_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)


func _apply_gravity(delta: float) -> void:
	if is_on_floor() and velocity.y >= 0.0:
		return

	var active_gravity := gravity if velocity.y < 0.0 else fall_gravity
	velocity.y = minf(velocity.y + active_gravity * delta, max_fall_speed)


func _try_jump() -> void:
	if jump_buffer_timer <= 0.0 or coyote_timer <= 0.0:
		return

	velocity.y = jump_velocity
	coyote_timer = 0.0
	jump_buffer_timer = 0.0


func _apply_jump_cut() -> void:
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier

class_name Player
extends CharacterBody2D

signal landed_on_surface(collider: Object)

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

@export_category("Double Jump")
@export var double_jump_velocity: float = -540.0
@export_range(1, 999, 1) var double_jump_cost: int = 25

@export_category("Gravity")
@export var gravity: float = 1450.0
@export var fall_gravity: float = 2300.0
@export var max_fall_speed: float = 1050.0

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var normal_jump_started: bool = false
var double_jump_used: bool = false
var active_pipe: Node2D
var _nearby_pipes: Array[Node2D] = []
var _pipe_regrab_blocked: bool = false

@onready var run_state: RunState = get_node_or_null("../../../RunState") as RunState


func _physics_process(delta: float) -> void:
	if _process_pipe_interaction(delta):
		return

	var was_on_floor := is_on_floor()
	_update_jump_timers(delta, was_on_floor)
	_apply_horizontal_movement(delta, was_on_floor)
	_apply_gravity(delta)
	_try_jump()
	_apply_jump_cut()
	move_and_slide()
	if not was_on_floor and is_on_floor():
		_emit_landing_surface()
	if is_on_floor():
		normal_jump_started = false
		double_jump_used = false


func enter_pipe(pipe: Node2D) -> void:
	if pipe == null:
		return
	if not _nearby_pipes.has(pipe):
		_nearby_pipes.append(pipe)
	if not is_zero_approx(Input.get_axis("move_left", "move_right")) or _pipe_regrab_blocked:
		return
	_attach_pipe(pipe)


func _attach_pipe(pipe: Node2D) -> void:
	active_pipe = pipe
	velocity = Vector2.ZERO
	coyote_timer = 0.0
	jump_buffer_timer = 0.0


func exit_pipe(pipe: Node2D) -> void:
	_nearby_pipes.erase(pipe)
	if active_pipe == pipe:
		active_pipe = _latest_nearby_pipe()


func clear_pipe_state() -> void:
	active_pipe = null
	_nearby_pipes.clear()
	_pipe_regrab_blocked = false


func _process_pipe_interaction(delta: float) -> bool:
	if not Input.is_action_pressed("move_up"):
		_pipe_regrab_blocked = false
	if active_pipe == null and not _pipe_regrab_blocked and Input.is_action_pressed("move_up") and is_zero_approx(Input.get_axis("move_left", "move_right")):
		var nearby_pipe := _latest_nearby_pipe()
		if nearby_pipe != null:
			_attach_pipe(nearby_pipe)
	if active_pipe == null:
		return false
	if not is_instance_valid(active_pipe):
		active_pipe = _latest_nearby_pipe()
		if active_pipe == null:
			return false

	if Input.is_action_just_pressed("jump"):
		active_pipe = null
		_pipe_regrab_blocked = true
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
		normal_jump_started = true
		velocity.y = jump_velocity
		_apply_horizontal_movement(delta, false)
		_apply_gravity(delta)
		_apply_jump_cut()
		move_and_slide()
		return true

	if not is_zero_approx(Input.get_axis("move_left", "move_right")):
		active_pipe = null
		return false

	velocity = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		velocity.y = -maxf(float(active_pipe.get("climb_speed")), 0.0)
	move_and_slide()
	return true


func _latest_nearby_pipe() -> Node2D:
	for index in range(_nearby_pipes.size() - 1, -1, -1):
		var pipe := _nearby_pipes[index]
		if is_instance_valid(pipe):
			return pipe
		_nearby_pipes.remove_at(index)
	return null


func _emit_landing_surface() -> void:
	for index in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		if collision.get_normal().dot(Vector2.UP) > 0.7:
			landed_on_surface.emit(collision.get_collider())
			return


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
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
		normal_jump_started = true
		double_jump_used = false
		return

	if not Input.is_action_just_pressed("jump"):
		return
	if is_on_floor() or not normal_jump_started or double_jump_used:
		return
	if run_state == null:
		return
	if not run_state.try_spend_energy(double_jump_cost):
		jump_buffer_timer = 0.0
		return

	velocity.y = double_jump_velocity
	double_jump_used = true
	jump_buffer_timer = 0.0


func _apply_jump_cut() -> void:
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier

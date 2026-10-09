class_name RunState
extends Node

signal energy_changed(current_energy: int, maximum_energy: int)
signal energy_depleted
signal lives_changed(current_lives: int)
signal floor_changed(current_floor: int, highest_floor: int)
signal timer_changed(elapsed_seconds: float)

@export_group("New Run Defaults")
@export_range(0, 999, 1) var max_energy: int = 100
@export_range(0, 999, 1) var starting_energy: int = 100
@export_range(0, 99, 1) var starting_lives: int = 9
@export_range(0.1, 5.0, 0.1) var timer_display_interval: float = 0.1

@export_group("Current Run")
@export var energy: int = 100:
	set(value):
		energy = clampi(value, 0, maxi(max_energy, 0))
		_emit_energy_changed_if_needed()
@export var lives: int = 9:
	set(value):
		lives = clampi(value, 0, maxi(starting_lives, 0))
		_emit_lives_changed_if_needed()
@export var current_floor: int = 1
@export var highest_floor: int = 1
@export var elapsed_seconds: float = 0.0:
	set(value):
		var safe_value := maxf(value, 0.0)
		if safe_value < elapsed_seconds and not _resetting_run:
			return
		elapsed_seconds = safe_value
		_emit_timer_changed_if_needed()
@export var timer_running: bool = false

var _resetting_run: bool = false
var _last_energy_value: int = -1
var _last_energy_maximum: int = -1
var _last_lives_value: int = -1
var _last_current_floor: int = -1
var _last_highest_floor: int = -1
var _last_timer_display_step: int = -1

func _process(delta: float) -> void:
	if timer_running:
		elapsed_seconds += maxf(delta, 0.0)

func reset_run() -> void:
	energy = clampi(starting_energy, 0, maxi(max_energy, 0))
	lives = maxi(starting_lives, 0)
	current_floor = 1
	highest_floor = 1
	_resetting_run = true
	elapsed_seconds = 0.0
	_resetting_run = false
	timer_running = true
	_emit_energy_changed_if_needed()
	_emit_lives_changed_if_needed()
	_emit_floor_changed_if_needed()
	_emit_timer_changed_if_needed()

func set_floor_progress(landed_floor: int) -> void:
	var safe_floor := maxi(landed_floor, 1)
	current_floor = safe_floor
	highest_floor = maxi(highest_floor, safe_floor)
	_emit_floor_changed_if_needed()

func stop_timer() -> void:
	timer_running = false

func try_spend_energy(amount: int) -> bool:
	if amount <= 0 or energy < amount:
		return false

	var previous_energy := energy
	energy -= amount
	if previous_energy > 0 and energy == 0:
		energy_depleted.emit()
	return true

func _emit_energy_changed_if_needed() -> void:
	if energy == _last_energy_value and max_energy == _last_energy_maximum:
		return
	_last_energy_value = energy
	_last_energy_maximum = max_energy
	energy_changed.emit(energy, max_energy)

func _emit_lives_changed_if_needed() -> void:
	if lives == _last_lives_value:
		return
	_last_lives_value = lives
	lives_changed.emit(lives)

func _emit_floor_changed_if_needed() -> void:
	if current_floor == _last_current_floor and highest_floor == _last_highest_floor:
		return
	_last_current_floor = current_floor
	_last_highest_floor = highest_floor
	floor_changed.emit(current_floor, highest_floor)

func _emit_timer_changed_if_needed() -> void:
	var interval := maxf(timer_display_interval, 0.1)
	var display_step := floori((elapsed_seconds + 0.000001) / interval)
	if display_step == _last_timer_display_step:
		return
	_last_timer_display_step = display_step
	timer_changed.emit(elapsed_seconds)

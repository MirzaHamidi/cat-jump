class_name HUD
extends Control

signal pause_requested

@export_node_path("RunState") var run_state_path: NodePath = NodePath("../../RunState")

@onready var energy_label: Label = $EnergyPanel/EnergyLabel
@onready var energy_bar: ProgressBar = $EnergyPanel/EnergyBar
@onready var life_pips: HBoxContainer = $EnergyPanel/LivesPips
@onready var floor_label: Label = $RunInfoPanel/FloorLabel
@onready var highest_floor_label: Label = $RunInfoPanel/HighestFloorLabel
@onready var timer_label: Label = $RunInfoPanel/TimerLabel
@onready var pause_button: Button = $RunInfoPanel/PauseButton

var run_state: RunState


func _ready() -> void:
	run_state = get_node_or_null(run_state_path) as RunState
	pause_button.pressed.connect(_on_pause_button_pressed)
	if run_state == null:
		push_error("HUD needs its RunState reference assigned in the Inspector.")
		return

	run_state.energy_changed.connect(_on_energy_changed)
	run_state.lives_changed.connect(_on_lives_changed)
	run_state.floor_changed.connect(_on_floor_changed)
	run_state.timer_changed.connect(_on_timer_changed)
	_on_energy_changed(run_state.energy, run_state.max_energy)
	_on_lives_changed(run_state.lives)
	_on_floor_changed(run_state.current_floor, run_state.highest_floor)
	_on_timer_changed(run_state.elapsed_seconds)


func set_pause_available(available: bool) -> void:
	pause_button.visible = available
	pause_button.disabled = not available


func _on_energy_changed(current_energy: int, maximum_energy: int) -> void:
	energy_label.text = "ENERGY %d / %d" % [current_energy, maximum_energy]
	energy_bar.max_value = maxf(float(maximum_energy), 1.0)
	energy_bar.value = current_energy


func _on_lives_changed(current_lives: int) -> void:
	for index in range(life_pips.get_child_count()):
		var pip := life_pips.get_child(index) as TextureRect
		if pip == null:
			continue
		var active := index < current_lives
		pip.modulate = Color.WHITE if active else Color(0.35, 0.35, 0.35, 0.35)


func _on_floor_changed(current_floor: int, highest_floor: int) -> void:
	floor_label.text = "FLOOR %03d" % current_floor
	highest_floor_label.text = "BEST %03d" % highest_floor


func _on_timer_changed(elapsed_seconds: float) -> void:
	var tenths_total := floori(maxf(elapsed_seconds, 0.0) * 10.0 + 0.000001)
	var minutes := floori(tenths_total / 600.0)
	var whole_seconds := floori(tenths_total / 10.0)
	var seconds := whole_seconds % 60
	var tenths := tenths_total % 10
	timer_label.text = "%02d:%02d.%d" % [minutes, seconds, tenths]


func _on_pause_button_pressed() -> void:
	pause_requested.emit()

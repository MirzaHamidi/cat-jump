class_name Victory
extends Control

const MAIN_MENU_SCENE_PATH := "res://Scenes/UI/MainMenu.tscn"

@onready var final_time_label: Label = $VictoryPanel/FinalTimeLabel
@onready var highest_floor_label: Label = $VictoryPanel/HighestFloorLabel
@onready var retry_button: Button = $VictoryPanel/RetryButton
@onready var title_button: Button = $VictoryPanel/TitleButton

var final_time_seconds: float = 0.0
var highest_floor: int = 1
var _transition_started := false


func _ready() -> void:
	retry_button.pressed.connect(_on_retry_button_pressed)
	title_button.pressed.connect(_on_title_button_pressed)
	_update_result_labels()
	retry_button.grab_focus()


func configure_result(elapsed_seconds: float, reached_floor: int) -> void:
	final_time_seconds = maxf(elapsed_seconds, 0.0)
	highest_floor = maxi(reached_floor, 1)
	if is_node_ready():
		_update_result_labels()


func _update_result_labels() -> void:
	var tenths_total := floori(final_time_seconds * 10.0 + 0.000001)
	var minutes := floori(tenths_total / 600.0)
	var seconds := floori(tenths_total / 10.0) % 60
	var tenths := tenths_total % 10
	final_time_label.text = "FINAL TIME  %02d:%02d.%d" % [minutes, seconds, tenths]
	highest_floor_label.text = "HIGHEST FLOOR  %03d" % highest_floor


func _on_retry_button_pressed() -> void:
	_request_scene_transition(true)


func _on_title_button_pressed() -> void:
	_request_scene_transition(false)


func _request_scene_transition(retry_run: bool) -> void:
	if _transition_started:
		return

	_transition_started = true
	retry_button.disabled = true
	title_button.disabled = true
	var scene_tree := get_tree()
	scene_tree.paused = false
	var error := scene_tree.reload_current_scene() if retry_run else scene_tree.change_scene_to_file(MAIN_MENU_SCENE_PATH)
	if error != OK:
		_transition_started = false
		retry_button.disabled = false
		title_button.disabled = false
		push_error("Victory could not change scenes. The result screen is still available.")

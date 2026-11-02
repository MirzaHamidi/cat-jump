class_name GameOver
extends Control

const MAIN_MENU_SCENE_PATH := "res://Scenes/UI/MainMenu.tscn"

@onready var final_time_label: Label = $GameOverPanel/FinalTimeLabel
@onready var highest_floor_label: Label = $GameOverPanel/HighestFloorLabel
@onready var lives_label: Label = $GameOverPanel/LivesLabel
@onready var retry_button: Button = $GameOverPanel/RetryButton
@onready var title_button: Button = $GameOverPanel/TitleButton

var final_time_seconds: float = 0.0
var highest_floor: int = 1
var lives_remaining: int = 0
var _transition_started := false


func _ready() -> void:
	retry_button.pressed.connect(_on_retry_button_pressed)
	title_button.pressed.connect(_on_title_button_pressed)
	_update_result_labels()
	retry_button.grab_focus()


func configure_result(elapsed_seconds: float, reached_floor: int, remaining_lives: int) -> void:
	final_time_seconds = maxf(elapsed_seconds, 0.0)
	highest_floor = maxi(reached_floor, 1)
	lives_remaining = maxi(remaining_lives, 0)
	if is_node_ready():
		_update_result_labels()


func _update_result_labels() -> void:
	var tenths_total := floori(final_time_seconds * 10.0 + 0.000001)
	var minutes := floori(tenths_total / 600.0)
	var seconds := floori(tenths_total / 10.0) % 60
	var tenths := tenths_total % 10
	final_time_label.text = "FINAL TIME  %02d:%02d.%d" % [minutes, seconds, tenths]
	highest_floor_label.text = "HIGHEST FLOOR  %03d" % highest_floor
	lives_label.text = "LIVES  %d" % lives_remaining


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
		push_error("GameOver could not change scenes. The result screen is still available.")

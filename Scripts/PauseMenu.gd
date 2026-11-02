class_name PauseMenu
extends Control

@export_node_path("Node2D") var run_controller_path: NodePath = NodePath("../..")
@export_node_path("HUD") var hud_path: NodePath = NodePath("../../HUDLayer/HUD")

const MAIN_MENU_SCENE_PATH := "res://Scenes/UI/MainMenu.tscn"

@onready var run_controller: RunController = get_node_or_null(run_controller_path) as RunController
@onready var hud: HUD = get_node_or_null(hud_path) as HUD
@onready var resume_button: Button = $PausePanel/ResumeButton
@onready var restart_button: Button = $PausePanel/RestartButton
@onready var title_button: Button = $PausePanel/TitleButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	resume_button.pressed.connect(_on_resume_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	title_button.pressed.connect(_on_title_button_pressed)
	if run_controller != null:
		run_controller.game_over_requested.connect(_on_terminal_state)
		if _is_terminal():
			_on_terminal_state()


func open_pause_menu() -> void:
	if _is_terminal():
		return
	get_tree().paused = true
	visible = true
	resume_button.grab_focus()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause") or event.is_echo():
		return
	if get_tree().paused:
		_on_resume_button_pressed()
	else:
		open_pause_menu()
	get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_inside_tree():
		call_deferred("_pause_after_focus_loss")


func _pause_after_focus_loss() -> void:
	if not is_inside_tree() or _is_terminal():
		return
	open_pause_menu()


func _on_resume_button_pressed() -> void:
	visible = false
	get_tree().paused = false
	get_viewport().gui_release_focus()


func _on_restart_button_pressed() -> void:
	var scene_tree := get_tree()
	scene_tree.paused = false
	var error := scene_tree.reload_current_scene()
	if error != OK:
		push_error("PauseMenu could not restart the current Run scene.")
		open_pause_menu()


func _on_title_button_pressed() -> void:
	var scene_tree := get_tree()
	scene_tree.paused = false
	var error := scene_tree.change_scene_to_file(MAIN_MENU_SCENE_PATH)
	if error != OK:
		push_error("PauseMenu could not return to the Main Menu scene.")
		open_pause_menu()


func _on_terminal_state() -> void:
	visible = false
	if get_tree().paused:
		get_tree().paused = false
	if hud != null:
		hud.set_pause_available(false)


func _is_terminal() -> bool:
	return run_controller != null and run_controller.run_mode == RunController.RunMode.TERMINAL

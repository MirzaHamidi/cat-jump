extends Node2D

@export var run_scene: PackedScene

@onready var start_button: Button = $MenuUI/Control/MenuButtons/StartButton

var _transition_started := false


func _on_start_button_pressed() -> void:
	if _transition_started:
		return

	if run_scene == null:
		push_error("MainMenu: Run Scene is not assigned. Assign Scenes/Levels/Run.tscn in the Inspector.")
		return

	_transition_started = true
	start_button.disabled = true

	var error := get_tree().change_scene_to_packed(run_scene)
	if error != OK:
		_transition_started = false
		start_button.disabled = false
		push_error("MainMenu: Could not start the assigned Run scene (error %d)." % error)


func _on_quit_button_pressed() -> void:
	get_tree().quit()

extends Node2D

enum RunMode { CLIMB, FIGHT, TERMINAL }

var run_mode: RunMode = RunMode.CLIMB
var active_encounter_reason: StringName = &""

@onready var run_state: RunState = $RunState

func _ready() -> void:
	run_mode = RunMode.CLIMB
	active_encounter_reason = &""
	run_state.reset_run()

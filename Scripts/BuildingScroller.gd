extends Node2D

const WINDOW_ROW: PackedScene = preload("res://Scenes/Gameplay/WindowRow.tscn")
const WindowRow = preload("res://Scripts/WindowRow.gd")

@export var player: CharacterBody2D
@export var camera: Camera2D
@export var floor_label: Label

@export_category("Building")
@export_range(1, 20, 1) var row_count: int = 20
@export_range(60.0, 200.0, 1.0) var row_spacing: float = 100.0
@export var first_row_y: float = 500.0
@export var debug_start_floor: int = 1

@export_category("Scrolling")
@export_range(100.0, 700.0, 1.0) var scroll_threshold_y: float = 420.0
@export_range(100.0, 2400.0, 10.0) var scroll_speed: float = 900.0

@onready var rows: Node2D = $Rows

var pooled_rows: Array[WindowRow] = []
var next_recycle_index: int = 0
var highest_row_y: float
var highest_pooled_floor: int
var current_floor: int
var highest_floor: int


func _ready() -> void:
	if player == null or camera == null or floor_label == null:
		push_error("BuildingScroller needs Player, Camera2D, and FloorLabel references.")
		set_physics_process(false)
		return

	row_count = clampi(row_count, 1, 20)
	row_spacing = maxf(row_spacing, 60.0)
	debug_start_floor = maxi(debug_start_floor, 1)
	current_floor = debug_start_floor
	highest_floor = debug_start_floor

	for index in range(row_count):
		var row: WindowRow = WINDOW_ROW.instantiate()
		row.name = "FloorRow%d" % index
		row.floor_number = debug_start_floor + index
		row.position.y = first_row_y - float(index) * row_spacing
		rows.add_child(row)
		pooled_rows.append(row)

	highest_row_y = pooled_rows.back().position.y
	highest_pooled_floor = pooled_rows.back().floor_number
	_update_hud()


func _physics_process(delta: float) -> void:
	_track_landed_floor()
	_scroll_camera(delta)
	_recycle_rows()


func _track_landed_floor() -> void:
	if not player.is_on_floor():
		return

	for index in range(player.get_slide_collision_count()):
		var collision: KinematicCollision2D = player.get_slide_collision(index)
		if collision.get_normal().y > -0.7:
			continue
		var collider := collision.get_collider() as Node
		if collider == null:
			continue
		var row := collider.get_parent() as WindowRow
		if row == null:
			continue
		current_floor = row.floor_number
		if current_floor > highest_floor:
			highest_floor = current_floor
			_update_hud()
		return


func _scroll_camera(delta: float) -> void:
	var half_height := get_viewport_rect().size.y * 0.5
	var target_y := player.global_position.y + half_height - scroll_threshold_y
	if target_y < camera.global_position.y:
		camera.global_position.y = move_toward(camera.global_position.y, target_y, scroll_speed * delta)


func _recycle_rows() -> void:
	var recycle_line_y := camera.global_position.y + get_viewport_rect().size.y * 0.5 + row_spacing
	while pooled_rows[next_recycle_index].global_position.y > recycle_line_y:
		var row := pooled_rows[next_recycle_index]
		highest_row_y -= row_spacing
		highest_pooled_floor += 1
		row.position.y = highest_row_y
		row.floor_number = highest_pooled_floor
		next_recycle_index = (next_recycle_index + 1) % row_count


func _update_hud() -> void:
	floor_label.text = "FLOOR %03d" % highest_floor

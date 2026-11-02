class_name Bird
extends Area2D

signal hit_requested(bird: Bird)
signal passed(bird: Bird)

@export_category("Movement")
@export_range(0.0, 2000.0, 1.0) var speed: float = 600.0

var target_player: CharacterBody2D
var camera: Camera2D

var _triggered := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if _triggered:
		return

	global_position.y += speed * delta
	if camera == null:
		return

	var visible_height := camera.get_viewport_rect().size.y / maxf(camera.zoom.y, 0.001)
	var screen_bottom := camera.get_screen_center_position().y + visible_height * 0.5
	if global_position.y > screen_bottom + 80.0:
		_finish_as_passed()


func _on_body_entered(body: Node2D) -> void:
	if _triggered or body != target_player:
		return

	_triggered = true
	set_deferred("monitoring", false)
	hit_requested.emit(self)
	queue_free()


func _finish_as_passed() -> void:
	if _triggered:
		return

	_triggered = true
	set_deferred("monitoring", false)
	passed.emit(self)
	queue_free()

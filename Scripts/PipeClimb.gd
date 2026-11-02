extends Node2D

@export_range(1.0, 600.0, 1.0) var climb_speed: float = 160.0


func _on_climb_area_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player:
		# A resumed physics area can report its pre-respawn overlap for one frame.
		# Check current scene transforms before accepting that contact.
		var area_shape := $ClimbArea/ClimbShape as CollisionShape2D
		var player_shape := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if area_shape == null or player_shape == null or area_shape.shape == null or player_shape.shape == null:
			return
		var area_bounds: Rect2 = area_shape.global_transform * area_shape.shape.get_rect()
		var player_bounds: Rect2 = player_shape.global_transform * player_shape.shape.get_rect()
		if not area_bounds.grow(20.0).intersects(player_bounds):
			return
		player.enter_pipe(self)


func _on_climb_area_body_exited(body: Node2D) -> void:
	var player := body as Player
	if player:
		player.exit_pipe(self)

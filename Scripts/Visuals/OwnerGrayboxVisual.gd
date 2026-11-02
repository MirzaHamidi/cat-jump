extends Node2D
## Poses the block arm without changing attack geometry.

@onready var arm: Line2D = $SwingArm
@onready var hand: Polygon2D = $Hand
@onready var resting_arm: Node2D = $RestArm


func pose_grip(global_grip: Vector2) -> void:
	var grip := to_local(global_grip)
	var side := 1.0 if global_grip.x >= global_position.x else -1.0
	var shoulder := Vector2(side * 51.0, -91.0)
	var lower_amount := clampf((grip.y + 180.0) / 140.0, 0.0, 1.0)
	var elbow := Vector2(side * lerpf(86.0, 76.0, lower_amount), lerpf(-145.0, -40.0, lower_amount))
	arm.points = PackedVector2Array([shoulder, elbow, grip])
	hand.position = grip
	hand.rotation = 0.0
	resting_arm.scale.x = side

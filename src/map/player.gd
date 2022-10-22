extends KinematicBody2D


const SPEED := 64.0


func _physics_process(_delta: float) -> void:
	var direction = Vector2(
		Input.get_action_strength("mov_right") - Input.get_action_strength("mov_left"),
		Input.get_action_strength("mov_down") - Input.get_action_strength("mov_up")
	).normalized()
	var _v = move_and_slide(SPEED * direction)

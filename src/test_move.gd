extends Sprite


func _physics_process(delta: float) -> void:
	var forcex = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var forcey = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	position += Vector2(forcex, forcey) * delta * 64

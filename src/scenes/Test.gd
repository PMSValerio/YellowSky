extends Node2D


func _physics_process(delta: float) -> void:
	var speed = 160
	if Input.get_action_strength("mov_left"):
		$Sprite.position.x -= delta * speed
	if Input.get_action_strength("mov_right"):
		$Sprite.position.x += delta * speed
	if Input.get_action_strength("mov_up"):
		$Sprite.position.y -= delta * speed
	if Input.get_action_strength("mov_down"):
		$Sprite.position.y += delta * speed
	
	$ParallaxBackground/ParallaxLayer3.motion_offset.x -= 10 * delta

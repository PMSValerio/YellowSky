extends Node2D
var can_interact = false
var can_move = true

func _physics_process(delta: float) -> void:
	if can_move == true:
		var forcex = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		var forcey = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		position += Vector2(forcex, forcey) * delta * 64

		
func _process(_delta):
	if Input.is_action_just_pressed("Interact") && can_interact == true:
		UI.visible = !UI.visible
		can_move = !can_move

func _on_Area2D_body_entered(body:Node):
	print("bodyentered:" + body.name)

func _on_TestMap_tile_entered(id: int):
	if id == 1:
		$Sprite/InteractPrompt.visible = true
		can_interact = true
	else:
		$Sprite/InteractPrompt.visible = false
		can_interact = false






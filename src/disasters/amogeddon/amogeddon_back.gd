extends Node2D


onready var start_pos = $Sprite.position

var _running = false


func _physics_process(_delta: float) -> void:
	if _running:
		$Sprite.position.y += 0.2


func play(running = true):
	_running = running
	if running:
		visible = true
	else:
		visible = false
		$Sprite.position = start_pos

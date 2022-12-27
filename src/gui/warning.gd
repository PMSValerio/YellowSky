extends Node2D


var mouse_in = false


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if mouse_in:
				visible = false


func _on_MenuTooltipProxy_mouse_entered() -> void:
	mouse_in = true


func _on_MenuTooltipProxy_mouse_exited() -> void:
	mouse_in = false

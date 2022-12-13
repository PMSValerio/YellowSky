extends Control





func _on_Button_pressed() -> void:
	EventManager.emit_signal("pop_menu")

extends Control


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ctrl_pause"):
		get_tree().set_input_as_handled()
		_on_Resume_pressed()


func _on_Resume_pressed() -> void:
	EventManager.emit_signal("pop_menu")


func _on_QuitDesktop_pressed() -> void:
	get_tree().quit()

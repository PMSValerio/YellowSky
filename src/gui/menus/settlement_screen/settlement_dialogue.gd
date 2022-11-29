extends Control

func _on_LeaveButton_pressed():
	EventManager.emit_signal("pop_menu")

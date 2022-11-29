extends Control


func _on_LeaveButton_pressed():
	EventManager.emit_signal("pop_menu")


func _on_TalkButton_pressed():
	EventManager.emit_signal("push_menu", Global.Menus.SETTLEMENT_DIALOGUE_SCREEN, null)

extends Control


func _on_Sub_pressed() -> void:
	EventManager.emit_signal("push_menu", Global.Menus.SUBTEST)


func _on_Button_pressed() -> void:
	EventManager.emit_signal("pop_menu")

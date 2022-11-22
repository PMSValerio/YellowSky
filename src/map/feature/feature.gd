extends Node2D
class_name Feature

func interact() -> void:
	print("feature")
	EventManager.emit_signal("push_menu", Global.Menus.TEST, null)

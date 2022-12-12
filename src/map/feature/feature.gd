extends Node2D
class_name Feature

func interact() -> void:
	print("feature")
	EventManager.emit_signal("push_menu", Global.Menus.TEST, null)


func mouse_entered() -> void:
	pass


func mouse_exited() -> void:
	pass

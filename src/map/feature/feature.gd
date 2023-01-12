extends Node2D
class_name Feature


func interact() -> void:
	if has_node("Warning"):
		$Warning.visible = false
	EventManager.emit_signal("push_menu", Global.Menus.TEST, null)


func _physics_process(_delta: float) -> void:
	if has_node("Warning"):
		$Warning.global_position = $Sprite.global_position + Vector2(0, -32) * $Sprite.scale
		#print("%s - %s" % [$Warning.global_position, $Warning/MenuTooltipProxy.rect_global_position])


func mouse_entered() -> void:
	pass


func mouse_exited() -> void:
	pass

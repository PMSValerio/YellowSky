extends Node2D
class_name Feature

var occupied_cells = []


func _ready() -> void:
	EventManager.emit_signal("feature_tile_placed", self)


func interact() -> void:
	if has_node("Warning"):
		$Warning.visible = false
	EventManager.emit_signal("push_menu", Global.Menus.TEST, null)


func _physics_process(_delta: float) -> void:
	if has_node("Warning"):
		$Warning.global_position = $Sprite.global_position + Vector2(0, -32) * $Sprite.scale


func mouse_entered() -> void:
	pass


func mouse_exited() -> void:
	pass


func die() -> void:
	EventManager.emit_signal("feature_tile_left", self)
	queue_free()

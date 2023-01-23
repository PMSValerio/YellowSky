extends Node2D
class_name Feature

var occupied_cells = []
var warning = null


func _ready() -> void:
	EventManager.emit_signal("feature_tile_placed", self)
	if has_node("Warning"):
		warning = $Warning
	else:
		warning = load("res://src/gui/Warning.tscn").instance()
		add_child(warning)
		warning.visible = false


func interact() -> void:
	if has_node("Warning"):
		warning.visible = false
	EventManager.emit_signal("push_menu", Global.Menus.TEST, null)


func _physics_process(_delta: float) -> void:
	if has_node("Warning"):
		warning.global_position = $Sprite.global_position + Vector2(0, -32) * $Sprite.scale


func mouse_entered() -> void:
	pass


func mouse_exited() -> void:
	pass


func set_discovered(discovered = true):
	visible = discovered


func die() -> void:
	EventManager.emit_signal("feature_tile_left", self)
	queue_free()

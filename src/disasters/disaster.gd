extends Node2D
class_name Disaster

# warning-ignore:unused_signal
signal disaster_end

export var shake_strength = 0.0 setget set_shake
export(PackedScene) var background_scene_path

var background_layer
var back = null


func _ready() -> void:
	if background_layer != null and background_scene_path != null:
		back = background_scene_path.instance()
		background_layer.add_child(back)


func start() -> void:
	pass


func set_shake(_shake_strength):
	shake_strength = _shake_strength
	Global.get_cam().set_shake(shake_strength)

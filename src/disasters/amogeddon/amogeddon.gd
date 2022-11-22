extends Disaster


var background_scene = preload("res://src/disasters/amogeddon/AmogeddonBack.tscn")
var back = null

export var shake_strength = 0.0 setget set_shake


func _ready() -> void:
	if background_layer != null:
		back = background_scene.instance()
		background_layer.add_child(back)


func start() -> void:
	$AnimationPlayer.play("play")


func set_shake(_shake_strength):
	shake_strength = _shake_strength
	Global.get_cam().set_shake(shake_strength)


func play_back(running : bool = true):
	if back != null:
		back.play(running)


func _on_anim_end(_anim_name) -> void:
	back.queue_free()
	back = null
	emit_signal("disaster_end")

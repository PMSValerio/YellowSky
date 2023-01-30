extends Disaster


onready var rains = $Rain


func start() -> void:
	$AnimationPlayer.play("play")
	for child in rains.get_children():
		child.play(child.name)


func set_rain_speed(speed : float, rain_ix : int):
	rains.get_child(rain_ix).speed_scale = speed


func map_rain(period : float):
	EventManager.emit_signal("rain", period)


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	emit_signal("disaster_end")

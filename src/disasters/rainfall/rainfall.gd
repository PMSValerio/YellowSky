extends Disaster


onready var rains = $Rain


func start() -> void:
	$AnimationPlayer.play("play")
	for child in rains.get_children():
		child.play(child.name)


func set_rain_speed(speed : float, rain_ix : int):
	rains.get_child(rain_ix).speed_scale = speed

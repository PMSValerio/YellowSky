extends Disaster


func start() -> void:
	$AnimationPlayer.play("play")


func background_in():
	back.anim(true)


func background_out():
	back.anim(false)

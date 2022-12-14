extends Disaster


func start() -> void:
	$AnimationPlayer.play("play")


func play_back(running : bool = true):
	if back != null:
		back.play(running)


func _on_anim_end(_anim_name) -> void:
	back.queue_free()
	back = null
	emit_signal("disaster_end")

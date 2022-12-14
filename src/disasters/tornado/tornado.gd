extends Disaster


func start() -> void:
	$AnimationPlayer.play("play")


func background_in():
	back.anim(true)


func background_out():
	back.anim(false)


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	back.queue_free()
	back = null
	emit_signal("disaster_end")

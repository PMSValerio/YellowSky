extends Disaster


func start() -> void:
	$AnimationPlayer.play("play")


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	emit_signal("disaster_end")

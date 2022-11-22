extends Disaster


export var shake_strength = 0.0 setget set_shake


func start() -> void:
	$AnimationPlayer.play("play")


func set_shake(_shake_strength):
	shake_strength = _shake_strength
	Global.get_cam().set_shake(shake_strength)


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	emit_signal("disaster_end")

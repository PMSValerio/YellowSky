extends Disaster


func _ready() -> void:
	back.connect("anim_end", self, "_on_back_anim_end")


func start():
	back.start()


func end():
	back.end()


func _on_back_anim_end(_start):
	if _start:
		$AnimationPlayer.play("play")
	else:
		back.queue_free()
		back = null
		emit_signal("disaster_end")


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	back.end()

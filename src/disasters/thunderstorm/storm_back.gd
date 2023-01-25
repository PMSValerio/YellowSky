extends Node2D


signal anim_end(_start)

var _start = true


func start():
	$AnimationPlayer.play("fade_in", -1, 0.5)
	_start = true


func end():
	$AnimationPlayer.play("fade_in", -1, -0.5, true)
	_start = false


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	emit_signal("anim_end", _start)

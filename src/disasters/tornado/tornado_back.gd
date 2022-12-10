extends Node2D


func anim(fade_in = true):
	$AnimationPlayer.play("play_in" if fade_in else "play_out")

extends Control

onready var polygon = $Polygon2D
onready var anim_player = $AnimationPlayer


func play():
	anim_player.play("idle")


func pause():
	anim_player.stop(false)

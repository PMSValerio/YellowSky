extends Node2D

export var shake_strength = 0.0 setget set_shake

func set_shake(_shake_strength):
	shake_strength = _shake_strength
	print(shake_strength);
	Global.get_cam().set_shake(shake_strength)

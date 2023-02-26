extends Node


onready var back_clouds = $ParallaxBackground/BackClouds
onready var front_clouds = $ParallaxBackground/FrontClouds
onready var bg_music = $BG_music
onready var start_sfx = $Start_sfx
onready var animation_player = $AnimationPlayer

var speed1 = 8
var speed2 = 16
var pressed = false
var in_title = false


func _ready():
	bg_music.play()
	Global.fade_in_bg_music(1.5)


func _physics_process(delta: float) -> void:
	back_clouds.motion_offset.x -= speed1 * delta
	front_clouds.motion_offset.x -= speed2 * delta


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			if in_title:
				if not pressed:
					start_sfx.play()
					animation_player.play("start_game")
					Global.fade_out_bg_music(2)
					pressed = true
			else:
				animation_player.advance(animation_player.current_animation_length)


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	if _anim_name == "opening":
		animation_player.play("start_title")
	elif _anim_name == "start_title":
		in_title = true
		animation_player.play("idle_menu")
	elif _anim_name == "start_game":
		var _v = get_tree().change_scene("res://src/scenes/World.tscn")
	
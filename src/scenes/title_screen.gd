extends Node


onready var layer1 = $ParallaxBackground/Layer1
onready var layer2 = $ParallaxBackground/Layer2
onready var bg_music = $BG_music_player
onready var start_sfx = $Start_sfx

var speed1 = 16
var speed2 = 8
var pressed = false

var in_title = false

func _ready():
	bg_music.play()
	Global.fade_in_bg_music(1.5)

func _physics_process(delta: float) -> void:
	layer1.motion_offset.x -= speed1 * delta
	layer2.motion_offset.x -= speed2 * delta

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			if in_title:
				if not pressed:
					start_sfx.play()
					$AnimationPlayer.play("start_game")
					Global.fade_out_bg_music(2)
					pressed = true
			else:
				$AnimationPlayer.advance($AnimationPlayer.current_animation_length)
	
func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	if _anim_name == "opening":
		$AnimationPlayer.play("start_title")
	elif _anim_name == "start_title":
		in_title = true
	elif _anim_name == "start_game":
		var _v = get_tree().change_scene("res://src/scenes/World.tscn")
		





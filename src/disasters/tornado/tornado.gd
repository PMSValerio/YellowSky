extends Disaster

onready var sfx = $sfx
onready var world_bg_music = get_node("/root/World/BG_MusicPlayer")

func _ready():
	Global.fade_between_audio(world_bg_music, sfx, 2)
	
func start() -> void:
	$AnimationPlayer.play("play")

func background_in():
	back.anim(true)

func background_out():
	back.anim(false)

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	back.queue_free()
	back = null
	Global.play_paused_audio(world_bg_music, 1.5)
	emit_signal("disaster_end")

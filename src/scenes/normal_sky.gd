extends ParallaxBackground


onready var clouds1 := $Clouds

var clouds1_speed = 10


func _physics_process(delta: float) -> void:
	clouds1.motion_offset.x += clouds1_speed * delta

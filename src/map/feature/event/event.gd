extends Feature
class_name Event

onready var sprite = $Sprite
onready var anim = $AnimationPlayer
onready var warning = $Warning

var data : EventData

var _readied = false


func _ready() -> void:
	_readied = true
	set_data(data)


func interact() -> void:
	EventManager.emit_signal("push_menu", Global.Menus.EVENT_SCREEN, self)
	warning.toggle(false)


func set_data(_data : EventData):
	data = _data
	if _readied:
		anim.play(data["animation"])

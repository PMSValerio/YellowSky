extends Feature
class_name Event

onready var sprite = $Sprite
onready var anim = $AnimationPlayer
onready var warning = $Warning

var die_on_interact = true
var cell_pos = Vector2(-1, -1)
var associated_quest = null

var data : EventData

var _readied = false


func _ready() -> void:
	_readied = true
	set_data(data)


func interact() -> void:
	if associated_quest == null or associated_quest.can_advance():
		EventManager.emit_signal("push_menu", Global.Menus.EVENT_SCREEN, self)
		warning.toggle(false)
	else:
		EventManager.emit_signal("push_menu", Global.Menus.EVENT_REQUIREMENTS_SCREEN, self)


func set_data(_data : EventData):
	data = _data
	if _readied:
		anim.play(data["animation"])


func set_associated_quest(quest):
	associated_quest = quest

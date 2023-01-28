extends Feature
class_name Event

onready var sprite = $Sprite
onready var anim = $AnimationPlayer

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


func toggle_warning(onoff = true):
	if associated_quest == null:
		warning.set_type(Global.Warnings.MSQ, "Point of interest")
	else:
		warning.set_type(Global.Warnings.QUEST, associated_quest.name)
	warning.toggle(onoff)


func export_data() -> Dictionary:
	var dict = {}
	
	dict["position"] = global_position
	dict["event_id"] = data.event_id
	dict["event_type"] = data.type
	dict["die_on_interact"] = die_on_interact
	dict["quest_id"] = null if associated_quest == null else associated_quest.quest_id
	
	return dict


func load_data(dict : Dictionary):
	global_position = dict["posiiton"]
	set_data(Global.get_event_data(dict["event_id"], dict["event_type"]))
	die_on_interact = dict["die_on_interact"]
	associated_quest = null if dict["quest_id"] == null else WorldData.quest_log.get_quest(dict["quest_id"])

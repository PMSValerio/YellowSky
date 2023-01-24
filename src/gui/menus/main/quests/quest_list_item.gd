extends MarginContainer


signal pressed

onready var icon = $MarginContainer/HBoxContainer/Icon
onready var title = $MarginContainer/HBoxContainer/Title

var data : Quest

var _readied = false


func _ready() -> void:
	_readied = true
	set_data(data)


func set_data(_data : Quest):
	data = _data
	
	if not _readied or data == null:
		return
	
	title.text = data.name
	
	# set icon and graphics according to status
	match data.get_status():
		Quest.Status.EVENT, Quest.Status.RETURN:
			pass
		Quest.Status.COMPLETE:
			pass
		Quest.Status.FAILED:
			pass


func _on_Button_pressed() -> void:
	emit_signal("pressed")

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
	var xx = 64
	match data.get_status():
		Quest.Status.EVENT:
			if not data.can_advance():
				xx = 0
		Quest.Status.RETURN:
			if data.can_advance():
				xx = 128
	icon.texture.region.position.x = xx


func _on_Button_pressed() -> void:
	emit_signal("pressed")

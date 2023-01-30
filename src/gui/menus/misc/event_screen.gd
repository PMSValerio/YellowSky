extends Control


onready var title = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Title
onready var flavour_text = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/FalvourTextContainer/Text
onready var dialogue_pntr = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/FalvourTextContainer/DialoguePointer
onready var grid = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer
onready var keyboard_sfx = $Keyboard_sfx

var event_entity : Event = null
var _readied

var _text_speed = 0.03
var _text_in_progress = false

var _stop_index = 0
var _total_index = 0
var paragraph_num = 1

var parsed_string = ""


func _ready() -> void:
	$BG_music_player.play()
	_readied = true
	set_context(event_entity)


func set_context(context):
	if context is Event:
		event_entity = context
		
	if _readied and event_entity != null:
		title.text = event_entity.data.title
		flavour_text.text = event_entity.data.flavour_text
		flavour_text.get_node("Timer").wait_time = _text_speed
		flavour_text.visible_characters = 0
		
		var items = event_entity.data.item_updates
		grid.populate_items(items)

		parsed_string = flavour_text.text
		parsed_string = parsed_string.replace(" ","") # remove spaces to get visible chars only
		_stop_index = parsed_string.find("\n\n")
		
		next_line()


func next_line():
	dialogue_pntr.pause()
	_text_in_progress = true
	
	# scroll through letters, instead of displaying them all at once
	keyboard_sfx.play()
	for _i in range(_stop_index - _total_index):
		if _text_in_progress: 
			flavour_text.visible_characters += 1
			flavour_text.get_node("Timer").start()
			yield(flavour_text.get_node("Timer"), "timeout")
		else:
			flavour_text.visible_characters = _stop_index
	keyboard_sfx.stop()
	
	_total_index = _stop_index
	# magic numbers are due to the fact that parsed string still has the "/n/n"s, but only the n's, i.e. 2 per paragraph
	_stop_index = (parsed_string.find("\n\n", _stop_index + (paragraph_num * 2))) - (paragraph_num * 2)
	paragraph_num += 1
	_text_in_progress = false

	# stop_index will be negative if there are no more substrings to be found
	if _stop_index < 0:
		dialogue_pntr.pause()
		dialogue_pntr.visible = false
	else:
		dialogue_pntr.play()
	

func _on_Button_pressed() -> void:
	# add event items to player inventory
	for item_id in event_entity.data.item_updates:
		var t = InventoryManager.item_stats[item_id].type
		InventoryManager.inventory.add_items(t, item_id, event_entity.data.item_updates[item_id])

	EventManager.emit_signal("pop_menu")
	if event_entity.data.type == Global.EventTypes.GENERIC:
		event_entity.data.item_updates = {}
	if event_entity.die_on_interact:
		event_entity.die()


func _on_FalvourTextContainer_gui_input(event:InputEvent):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1 && dialogue_pntr.visible):
		# clicking while flavour_text is being displayed will instantly show the currently scrolling flavour_text
		if _text_in_progress:
			_text_in_progress = false
		else:
			# if the scroll was already finished, clicking will show new line
			next_line()

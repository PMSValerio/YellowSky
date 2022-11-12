extends Node2D


onready var item_list := $PanelContainer/VBoxContainer


# generic function, receives a dictionary of values to display on tooltip; override if necessary
func update_items(items : Dictionary) -> void:
	for child in item_list.get_children():
		child.queue_free()
	
	for key in items.keys():
		var label = Label.new()
		label.clip_text = true
		label.text = str(key) + ": " + str(items[key])
		item_list.add_child(label)

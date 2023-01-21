extends Control


onready var title = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Title
onready var text = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Text
onready var grid = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer

var event_entity : Event = null
var _readied


func _ready() -> void:
	_readied = true
	set_context(event_entity)


func set_context(context):
	if context is Event:
		event_entity = context
		
	if _readied and event_entity != null:
		title.text = event_entity.data.title
		text.text = event_entity.data.flavour_text
		
		var items = event_entity.data.item_updates
		for i in range(items.size()):
			if i >= grid.get_child_count(): # stop at the amount of grid slots max
				break
			var item_id = items.keys()[i]
			
			grid.get_child(i).populate_data(InventoryManager.item_stats[item_id], items[item_id])


func _on_Button_pressed() -> void:
	for item_id in event_entity.data.item_updates:
		var t = InventoryManager.item_stats[item_id].type
		InventoryManager.inventory.add_items(t, item_id, event_entity.data.item_updates[item_id])
		EventManager.emit_signal("pop_menu")

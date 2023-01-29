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
		grid.populate_items(items)


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

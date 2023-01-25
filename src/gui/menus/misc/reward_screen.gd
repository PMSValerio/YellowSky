extends PanelContainer

onready var flavour_text = $MarginContainer/VBoxContainer/FlavourText
onready var grid = $MarginContainer/VBoxContainer/GridContainer

var quest_entity : Quest = null
var items = {}


func set_context(context):
	if context is Quest:
		quest_entity = context

		flavour_text.text = quest_entity.description		
		items = quest_entity.rewards
		grid.populate_items(items)
		

func _on_AcceptButton_pressed():
	for item_id in items:
		var t = InventoryManager.item_stats[item_id].type
		InventoryManager.inventory.add_items(t, item_id, items[item_id])

	visible = false

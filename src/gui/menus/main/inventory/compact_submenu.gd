extends PanelContainer


signal update_items

# Compact Submenu Nodes
onready var compact_resource_icon = $VBoxContainer/HBoxContainer/ResourceIcon
onready var compact_transaction_value = $VBoxContainer/HBoxContainer/TransactionValue
onready var compact_item_list = $VBoxContainer/MarginContainer/CompactItems


var resource_id


onready var ResourceManager = Global.get_player().get_node("ResourceManager") # <- this is very bad, Resource should be global, maybe?


func _ready() -> void:
	for button in compact_item_list.get_children():
		button.connect("pressed", self, "_on_compact_item_pressed", [button])


func toggle_on(rec_id, resource_icon):
	resource_id = rec_id
	
	visible = true
	compact_resource_icon.texture = resource_icon
	compact_transaction_value.text = str(ResourceManager.get_resource(resource_id))
	
	var ix = 0
	for item_id in InventoryManager.get_all_compact_ids(resource_id):
		var item_data : Item = InventoryManager.item_stats[item_id]
		var cost = int(ceil(float(item_data.stat) * 1.2))
		var too_expensive = cost > ResourceManager.get_resource(resource_id)
		compact_item_list.get_children()[ix].set_state(item_data, too_expensive, cost)
		
		ix += 1
	while ix < compact_item_list.get_child_count():
		compact_item_list.get_children()[ix].clear()
		ix += 1


func _on_compact_item_pressed(button : CompactTransactionSlot) -> void:
	InventoryManager.add_item(button.data.type, button.data.id)
	ResourceManager.add_to_resource(resource_id, -button.cost)
	emit_signal("update_items")
	visible = false


func _on_CancelCompactButton_pressed() -> void:
	visible = false

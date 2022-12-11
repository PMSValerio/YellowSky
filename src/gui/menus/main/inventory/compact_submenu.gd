extends PanelContainer


signal update_items

# Compact Submenu Nodes
onready var water_tab = $VBoxContainer/ResourceTabs/WaterButton
onready var energy_tab = $VBoxContainer/ResourceTabs/EnergyButton
onready var material_tab = $VBoxContainer/ResourceTabs/MaterialButton

onready var compact_item_list = $VBoxContainer/MarginContainer/CompactItems


var resource_id


onready var ResourceManager = Global.get_player().get_node("ResourceManager") # <- this is very bad, Resource should be global, maybe?


func _ready() -> void:
	for button in compact_item_list.get_children():
		button.connect("pressed", self, "_on_compact_item_pressed", [button])
	
	water_tab.connect("pressed", self, "_on_tab_selected", [Global.FacilityResources.WATER])
	water_tab.text = str(ResourceManager.get_resource(Global.FacilityResources.WATER))
	energy_tab.connect("pressed", self, "_on_tab_selected", [Global.FacilityResources.ENERGY])
	energy_tab.text = str(ResourceManager.get_resource(Global.FacilityResources.ENERGY))
	material_tab.connect("pressed", self, "_on_tab_selected", [Global.FacilityResources.MATERIALS])
	material_tab.text = str(ResourceManager.get_resource(Global.FacilityResources.MATERIALS))


func toggle_on(rec_id):
	resource_id = rec_id
	
	visible = true
	
	var ix = 0
	for item_id in InventoryManager.get_all_compact_ids(resource_id):
		var item_data : Item = InventoryManager.item_stats[item_id]
		var cost = int(ceil(float(item_data.stat) * Global.COMPACT_LOSS))
		var too_expensive = cost > ResourceManager.get_resource(resource_id)
		compact_item_list.get_children()[ix].set_state(item_data, too_expensive, cost)
		
		ix += 1
	while ix < compact_item_list.get_child_count():
		compact_item_list.get_children()[ix].clear()
		ix += 1
	
	water_tab.pressed = false
	water_tab.button_mask = BUTTON_MASK_LEFT
	energy_tab.pressed = false
	energy_tab.button_mask = BUTTON_MASK_LEFT
	material_tab.pressed = false
	material_tab.button_mask = BUTTON_MASK_LEFT
	match rec_id:
		Global.FacilityResources.WATER:
			water_tab.pressed = true
			water_tab.button_mask = 0
		Global.FacilityResources.ENERGY:
			energy_tab.pressed = true
			energy_tab.button_mask = 0
		Global.FacilityResources.MATERIALS:
			material_tab.pressed = true
			material_tab.button_mask = 0


func _on_compact_item_pressed(button : CompactTransactionSlot) -> void:
	InventoryManager.add_item(button.data.type, button.data.id)
	ResourceManager.add_to_resource(resource_id, -button.cost)
	emit_signal("update_items")
	visible = false


func _on_tab_selected(rec_id) -> void:
	toggle_on(rec_id)


func _on_CancelCompactButton_pressed() -> void:
	visible = false

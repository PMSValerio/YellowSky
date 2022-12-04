extends Control


# Item Grid Nodes
onready var item_grid = $MarginContainer/HBoxContainer/GridManager/ItemGrid
onready var resources_tab = $MarginContainer/HBoxContainer/GridManager/CategoryTabs/ResourcesTab
onready var food_tab = $MarginContainer/HBoxContainer/GridManager/CategoryTabs/FoodTab
onready var luxury_tab = $MarginContainer/HBoxContainer/GridManager/CategoryTabs/LuxuryTab
onready var quest_tab = $MarginContainer/HBoxContainer/GridManager/CategoryTabs/QuestTab

onready var water_button = $MarginContainer/HBoxContainer/GridManager/ResourcesPanel/WaterButton
onready var energy_button = $MarginContainer/HBoxContainer/GridManager/ResourcesPanel/EnergyButton
onready var materials_button = $MarginContainer/HBoxContainer/GridManager/ResourcesPanel/MaterialsButton

# Item Details Nodes
onready var details_panel = $MarginContainer/HBoxContainer/ItemDetails
onready var item_display = $MarginContainer/HBoxContainer/ItemDetails/PanelContainer/ItemDisplay
onready var item_description = $MarginContainer/HBoxContainer/ItemDetails/PanelContainer2/ItemDescription
onready var _use_btn_margin = $MarginContainer/HBoxContainer/ItemDetails/MarginContainer
onready var use_button = $MarginContainer/HBoxContainer/ItemDetails/MarginContainer/UseButton

onready var items_per_page = item_grid.get_child_count() # item_grid should already be populated with item slots
onready var rows = items_per_page / item_grid.columns

onready var compact_submenu = $CompactSubmenu

var _page_first_ix = 0 # the array index of the first item being shown in the current page
var _page_last_ix = -1 # the array index of the last item being shown in the current page

var grid_category = Global.Items.RESOURCES # category being examined by the grid
var inspected_slot : GridSlot = null # item currently highlighted in details panel

onready var ResourceManager = Global.get_player().get_node("ResourceManager") # <- this is very bad, Resource should be global, maybe?


func _ready() -> void:
	water_button.connect("action_pressed", self, "_on_resource_pressed", [Global.FacilityResources.WATER, water_button.get_resource_icon()])
	energy_button.connect("action_pressed", self, "_on_resource_pressed", [Global.FacilityResources.ENERGY, energy_button.get_resource_icon()])
	materials_button.connect("action_pressed", self, "_on_resource_pressed", [Global.FacilityResources.MATERIALS, materials_button.get_resource_icon()])
	
	resources_tab.connect("pressed", self, "_on_select_category", [Global.Items.RESOURCES])
	food_tab.connect("pressed", self, "_on_select_category", [Global.Items.FOOD])
	luxury_tab.connect("pressed", self, "_on_select_category", [Global.Items.LUXURY])
	quest_tab.connect("pressed", self, "_on_select_category", [Global.Items.QUEST])
	for child in item_grid.get_children():
		var _v = (child as GridSlot).button_node.connect("pressed", self, "_on_select_slot", [child])


func set_context(_context):
	_populate_item_grid(Global.Items.RESOURCES, 0)


# set resources
func _set_resources():
	water_button.set_value(ResourceManager.get_resource(Global.FacilityResources.WATER))
	energy_button.set_value(ResourceManager.get_resource(Global.FacilityResources.ENERGY))
	materials_button.set_value(ResourceManager.get_resource(Global.FacilityResources.MATERIALS))


# populate grid with <items_per_page> items starting from the first_ix in the ItemIds array onwards
func _populate_item_grid(type, first_ix, keep_inspected_slot = false):
	if not type in InventoryManager.inventory.keys(): # sanity check
		return
	
	grid_category = type
	
	for child in item_grid.get_children():
		child.clear_data()
	
	_page_first_ix = first_ix
	var item_ix = first_ix
	var items_shown = 0
	var ids_list = InventoryManager.get_all_ids_of_type(grid_category)
	while items_shown < items_per_page:
		if item_ix >= ids_list.size(): # if reached the last id, break
			break
		
		var id = ids_list[item_ix]
		var item_amount = InventoryManager.get_item_amount(grid_category, id)
		if item_amount > 0: # if player has the item, update slot
			var item_data = InventoryManager.item_stats[id]
			
			var slot = item_grid.get_node("GridSlot" + str(items_shown)) as GridSlot
			slot.populate_data(item_data, item_amount)
			
			items_shown += 1 # only update items shown if the slot was indeed modified
		item_ix += 1
	_page_last_ix = item_ix - 1
	
	var slot = inspected_slot if keep_inspected_slot else null
	_update_item_details(slot)


func _update_item_details(slot : GridSlot):
	inspected_slot = slot
	if slot == null or slot.data == null:
		details_panel.visible = false
		return
	details_panel.visible = true
	item_display.texture = slot.data.texture
	item_description.text = slot.data.flavour_text
	use_button.disabled = not slot.data.usable
	_use_btn_margin.visible = slot.data.usable


func _clean_up():
	_update_item_details(null)


# --- || Signal Callbacks || ---


func _on_UseButton_pressed() -> void:
	InventoryManager.use_item(grid_category, inspected_slot.data.id)
	inspected_slot.set_amount(InventoryManager.get_item_amount(grid_category, inspected_slot.data.id))
	if inspected_slot.amount <= 0: # if item was used up completely
		# repopulate item grid with the same page
		_populate_item_grid(grid_category, _page_first_ix)


func _on_resource_pressed(rec_id, icon) -> void:
	compact_submenu.toggle_on(rec_id, icon)
	


func _on_select_category(type) -> void:
	if type != grid_category:
		_populate_item_grid(type, 0)


func _on_select_slot(slot) -> void:
	_update_item_details(slot)


func _on_CompactSubmenu_update_items() -> void:
	_populate_item_grid(Global.Items.RESOURCES, _page_first_ix)

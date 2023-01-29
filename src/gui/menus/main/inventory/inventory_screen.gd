extends Control


# Item Grid Nodes
onready var item_grid = $MarginContainer/HBoxContainer/GridManager/PanelContainer/ItemGrid
onready var category_tabs = $MarginContainer/HBoxContainer/GridManager/CategoryTabs

# Item Details Nodes
onready var details_panel = $MarginContainer/HBoxContainer/ItemDetails
onready var item_name = $MarginContainer/HBoxContainer/ItemDetails/PanelContainer3/Name
onready var item_display = $MarginContainer/HBoxContainer/ItemDetails/PanelContainer/ItemDisplay
onready var item_description = $MarginContainer/HBoxContainer/ItemDetails/PanelContainer2/ItemDescription
onready var _use_btn_margin = $MarginContainer/HBoxContainer/ItemDetails/MarginContainer
onready var use_button = $MarginContainer/HBoxContainer/ItemDetails/MarginContainer/UseButton

onready var item_trade_container = $MarginContainer/HBoxContainer/ItemDetails/PanelContainer2/MarginContainer/HBoxContainer/Trade
onready var item_trade_value = $MarginContainer/HBoxContainer/ItemDetails/PanelContainer2/MarginContainer/HBoxContainer/Trade/HBoxContainer/Value
onready var item_stats_container = $MarginContainer/HBoxContainer/ItemDetails/PanelContainer2/MarginContainer/HBoxContainer/Stat
onready var item_stats_tooltip = $MarginContainer/HBoxContainer/ItemDetails/PanelContainer2/MarginContainer/HBoxContainer/Stat/MenuTooltipProxy
onready var item_stats_value = $MarginContainer/HBoxContainer/ItemDetails/PanelContainer2/MarginContainer/HBoxContainer/Stat/HBoxContainer/Value
onready var item_stats_icon = $MarginContainer/HBoxContainer/ItemDetails/PanelContainer2/MarginContainer/HBoxContainer/Stat/HBoxContainer/TextureRect
onready var _item_stats_margin = $MarginContainer/HBoxContainer/ItemDetails/PanelContainer2/MarginContainer


onready var items_per_page = item_grid.get_child_count() # item_grid should already be populated with item slots
onready var rows = items_per_page / item_grid.columns

onready var compact_submenu = $CompactSubmenu
onready var use_sfx = $Use_sfx
onready var open_sfx = $Backpack_sfx

var _page_first_ix = 0 # the array index of the first item being shown in the current page
var _page_last_ix = -1 # the array index of the last item being shown in the current page

var grid_category = Global.Items.RESOURCES # category being examined by the grid
var inspected_slot : GridSlot = null # item currently highlighted in details panel


func _ready() -> void:
	open_sfx.play()
	
	for child in item_grid.get_children():
		var _v = (child as GridSlot).button_node.connect("pressed", self, "_on_select_slot", [child])


func set_context(context):
	grid_category = -1
	category_tabs.select_category(Global.Items.RESOURCES)
	if context != null and context in Global.Resources.values():
		toggle_compact_menu_on(context)


# populate grid with <items_per_page> items starting from the first_ix in the ItemIds array onwards
func _populate_item_grid(type, first_ix, keep_inspected_slot = false):
	if not type in InventoryManager.inventory.get_inventory_keys() : # sanity check
		return
	
	grid_category = type
	
	for child in item_grid.get_children():
		child.clear_data()
	
	_page_first_ix = first_ix
	var item_ix = first_ix
	var items_shown = 0
	var ids_list = InventoryManager.inventory.get_all_ids_of_type(grid_category)
	while items_shown < items_per_page:
		if item_ix >= ids_list.size(): # if reached the last id, break
			break
		
		var id = ids_list[item_ix]
		var item_amount = InventoryManager.inventory.get_item_amount(grid_category, id)
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
	item_name.text = slot.data.name
	item_display.texture = slot.data.texture
	item_description.text = slot.data.flavour_text
	
	item_trade_value.text = str(slot.data.value)
	item_stats_container.visible = true
	item_stats_value.text = str(slot.data.stat)
	match slot.data.type:
		Global.Items.RESOURCES:
			item_stats_tooltip.hint_tooltip = "Yields " + str(slot.data.stat) + " " + Global.resource_names[slot.data.subtype]
			item_stats_icon.texture = Global.resource_icons[slot.data.subtype]
		Global.Items.FOOD:
			item_stats_tooltip.hint_tooltip = "Restores " + str(slot.data.stat) + " Stamina"
			item_stats_icon.texture = Global.resource_icons[Global.Resources.FOOD]
		Global.Items.LUXURY, Global.Items.QUEST:
			item_stats_container.visible = false
	
	_item_stats_margin.visible = slot.data.value > 0.0
	use_button.disabled = not slot.data.usable
	_use_btn_margin.visible = slot.data.usable


func _clean_up():
	_update_item_details(null)


# --- || Signal Callbacks || ---


func _on_UseButton_pressed() -> void:
	InventoryManager.inventory.use_item(grid_category, inspected_slot.data.id)
	_play_use_sfx(grid_category, inspected_slot.data.subtype)
	inspected_slot.set_amount(InventoryManager.inventory.get_item_amount(grid_category, inspected_slot.data.id))
	if inspected_slot.amount <= 0: # if item was used up completely
		# repopulate item grid within the same page
		_populate_item_grid(grid_category, _page_first_ix)


func toggle_compact_menu_on(rec_id) -> void:
	category_tabs.select_category(Global.Items.RESOURCES)
	compact_submenu.toggle_on(rec_id)


func _on_select_category(type) -> void:
	if type != grid_category:
		_populate_item_grid(type, 0)


func _on_select_slot(slot) -> void:
	_update_item_details(slot)


func _on_CompactSubmenu_update_items() -> void:
	_populate_item_grid(Global.Items.RESOURCES, 0)
	category_tabs.select_category(Global.Items.RESOURCES)


func _on_Tabs_tab_changed(tab: int) -> void:
	match tab:
		0:
			_on_select_category(Global.Items.RESOURCES)
		1:
			_on_select_category(Global.Items.FOOD)
		2:
			_on_select_category(Global.Items.LUXURY)
		3:
			_on_select_category(Global.Items.QUEST)

func _play_use_sfx(slot_category, item_subtype) -> void:
	var sound_effect = null
	match slot_category:
		Global.Items.RESOURCES:
			match item_subtype:
				"1":
					sound_effect = "res://assets/sfx/ui/UI_Use_Food.wav"
				"2":
					sound_effect = "res://assets/sfx/ui/UI_Use_Food.wav"
				"3":
					sound_effect = "res://assets/sfx/ui/UI_Use_Food.wav"
		Global.Items.FOOD:
			sound_effect = "res://assets/sfx/ui/UI_Use_Food.wav"
	use_sfx.stream = load(sound_effect)
	use_sfx.play()

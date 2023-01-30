extends MarginContainer

enum Sides {
	INVENTORY,
	SETTLEMENT
}

var template_grid_slot = preload("res://src/gui/menus/main/inventory/GridSlot.tscn")

onready var resource_slider = $PanelContainer/MarginContainer/ResourceSlider
# inventory areas
onready var inventory_grid = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PlayerArea/PanelContainer/ScrollInventory/InventoryGrid
onready var settlement_grid = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SettlementArea/PanelContainer/ScrollSettlement/SettlementGrid
# trade area
onready var trade_button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TradeArea/TradeButton
onready var inventory_bar = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TradeArea/PanelContainer/HBoxContainer/PlayerOffer/PlayerBar
onready var settlement_bar = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TradeArea/PanelContainer/HBoxContainer/SettlementOffer/SettlementBar
onready var player_offer_label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TradeArea/PanelContainer/HBoxContainer/PlayerOffer/PlayerOfferLabel
onready var settlement_offer_label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TradeArea/PanelContainer/HBoxContainer/SettlementOffer/SettlementOfferLabel

var settlement_entity : Settlement  = null
var player_offer : Inventory = null  
var settlement_offer : Inventory = null 
var extra_player_slots = [] # stores slots that are added when needed
var extra_settlement_slots = []

var grids = {}
var bars = {}
var bar_labels = {}
var item_sources = {}
var item_offerings = {}
var extra_slots = {}

var slot_batch_number : int = 0 # number of slots to add when items > slots already existant
var is_slider_active = false
var selected_slot = null
var selected_side = Sides.INVENTORY


func _ready():
	# set up offer inventories
	player_offer = Inventory.new()
	settlement_offer = Inventory.new()
	player_offer.init()
	settlement_offer.init()

	# programatically connect buttons to "on select" signals
	for child in inventory_grid.get_children():
		slot_batch_number += 1
		var _v = (child as GridSlot).connect("button_pressed", self, "_on_select_slot", [child, Sides.INVENTORY]) 
	for child in settlement_grid.get_children():
		var _v = (child as GridSlot).connect("button_pressed", self, "_on_select_slot", [child, Sides.SETTLEMENT]) 


	grids[Sides.INVENTORY] = inventory_grid
	grids[Sides.SETTLEMENT] = settlement_grid
	bars[Sides.INVENTORY] = inventory_bar
	bars[Sides.SETTLEMENT] = settlement_bar
	bar_labels[Sides.INVENTORY] = player_offer_label
	bar_labels[Sides.SETTLEMENT] = settlement_offer_label
	item_offerings[Sides.INVENTORY] = player_offer
	item_offerings[Sides.SETTLEMENT] = settlement_offer
	extra_slots[Sides.INVENTORY] = extra_player_slots
	extra_slots[Sides.SETTLEMENT] = extra_settlement_slots

	
func set_context(context) -> void:

	settlement_entity = context
	item_sources[Sides.INVENTORY] = InventoryManager
	item_sources[Sides.SETTLEMENT] = settlement_entity

	reset()


func _populate_item_grid(first_ix, side):

	# clean previous grid display
	for child in grids[side].get_children():
		child.clear_data()
		child.set_is_selected(false)

	var num_of_slots = grids[side].get_child_count()
	var item_ix = first_ix
	var items_shown = 0
	var owned_item_info_list = item_sources[side].inventory.get_owned_items_info() 

	# loop to populate each slot
	while items_shown < num_of_slots:

		# if reached the last id for the given type, break
		if item_ix >= owned_item_info_list.size(): 
			break
		
		var id = owned_item_info_list[item_ix][1]
		var item_amount = owned_item_info_list[item_ix][2]

		# if player has the item, update slot
		if item_amount > 0: 
			var item_data = InventoryManager.item_stats[id]
			var slot = grids[side].get_node("GridSlot" + str(items_shown)) as GridSlot
			slot.populate_data(item_data, item_amount)
			
			# only update items shown if the slot was indeed modified
			items_shown += 1

		item_ix += 1


# supports negative values if removing is what is needed
func offer_current_slot(amount):
	
	selected_slot.add_trade_amount(-amount)
	item_offerings[selected_side].add_items(selected_slot.data.type, selected_slot.data.id, amount)
	change_offer_value(selected_side, bars[selected_side].value + selected_slot.data.value * amount)
	check_trade_button()
	

func offer_remove_all(side):
	if item_offerings[side].get_owned_items_info().size() > 0:

		_populate_item_grid(0, side)
		item_offerings[side].reset()
		change_offer_value(side, 0)
	else:
		for child in grids[side].get_children():
			if child.data != null:
				child.add_trade_amount(-child.amount)
				item_offerings[side].add_items(child.data.type, child.data.id, child.amount)

		change_offer_value(side, bars[side].value + item_offerings[side].get_total_value())

	check_trade_button()


# check if trade is valid to enable/disable trade button
func check_trade_button():
	if player_offer.get_total_value() >= settlement_offer.get_total_value() && settlement_offer.get_total_value() > 0 && player_offer.get_total_value() > 0:
		trade_button.disabled = false
		trade_button.flat = false
	else:
		trade_button.disabled = true
		trade_button.flat = true


func change_offer_value(side, new_value):
	bars[side].value = new_value
	bar_labels[side].text = str(new_value)


func reset():

	for side in Sides.values():
		# add extra slots if necessary
		var item_dif = item_sources[side].inventory.get_owned_items_info().size() - grids[side].get_child_count()
		if item_dif > 0:
			# create additional slots 
			for _i in slot_batch_number:
				var new_slot : GridSlot = template_grid_slot.instance()
				new_slot.set_up_for_trade()
				extra_slots[side].append(new_slot)
				grids[side].add_child(new_slot, true)

			# programatically connect buttons to "on select" signals
			for slot in extra_slots[side]:
				var _v = (slot as GridSlot).connect("button_pressed", self, "_on_select_slot", [slot, side]) 

			
		_populate_item_grid(0, side)
		bars[side].max_value = max(InventoryManager.inventory.get_total_value(), settlement_entity.inventory.get_total_value())
		change_offer_value(side, 0)
		item_offerings[side].reset()
		check_trade_button()


# --- || Signal Callbacks || ---


# acts on slot upon left/right/middle mouse button click
func _on_select_slot(mouse_value, slot : GridSlot, side) -> void:
	if slot.data != null && !is_slider_active:
		
		selected_slot = slot
		selected_side = side

		match mouse_value:
			BUTTON_LEFT:
				offer_current_slot(1)
			BUTTON_MIDDLE:
				resource_slider.set_state(slot.temp_amount, 0, slot.amount, slot.data.texture, "Settlement")
				resource_slider.visible = true
				is_slider_active = true
			BUTTON_RIGHT:
				offer_current_slot(-(slot.amount - slot.temp_amount))


func _on_ResourceSlider_value_chosen(delta_value) -> void:
	is_slider_active = false
	offer_current_slot(delta_value)


func _on_PlayerButton_pressed():
	if !is_slider_active:
		offer_remove_all(Sides.INVENTORY)


func _on_SettlementButton_pressed():
	if !is_slider_active:
		offer_remove_all(Sides.SETTLEMENT)


func _on_TradeButton_pressed():
	if !is_slider_active:
		# duplicated code can be cleaned up, but becomes more cumbersome and unreadable
		for i in settlement_offer.get_owned_items_info():
			InventoryManager.inventory.add_items(i[0], i[1], i[2])
			settlement_entity.inventory.add_items(i[0], i[1], -i[2])
		for i in player_offer.get_owned_items_info():
			settlement_entity.inventory.add_items(i[0], i[1], i[2])
			InventoryManager.inventory.add_items(i[0], i[1], -i[2])
		reset()


func _on_ExitBtn_pressed():
	if !is_slider_active:
		reset()
		resource_slider.visible = false
		is_slider_active = false
		visible = false

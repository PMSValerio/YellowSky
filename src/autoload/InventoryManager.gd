extends Node


var ItemIds = [] # alternative to Items enum, still testing

var item_stats = {}

var inventory = {}


func _ready():
	for t in Global.Items.values(): # have a dictionary for each item type
		inventory[t] = {}
	
	# TODO: load item data from config files
	var type = Global.Items.FOOD
	var id = 0
	var item = Item.new()
	item.init(id, type, preload("res://assets/gfx/items/keg_o_water.png"), 5, 10, true)
	item_stats[id] = item
	inventory[type][id] = 3
	id += 1
	item = Item.new()
	item.init(id, type, preload("res://assets/gfx/items/gallon_of_water.png"), 10, 15, true)
	item_stats[id] = item
	inventory[type][id] = 5
	id += 1
	item = Item.new()
	item.init(id, type, preload("res://assets/gfx/items/water_bottle.png"), 15, 20, true)
	item_stats[id] = item
	inventory[type][id] = 1
	
	type = Global.Items.LUXURY
	id += 1
	item = Item.new()
	item.init(id, type, preload("res://assets/gfx/items/gallon_of_water.png"), 30, 0, true)
	item_stats[id] = item
	inventory[type][id] = 4
	
	type = Global.Items.QUEST
	id += 1
	item = Item.new()
	item.init(id, type, preload("res://assets/gfx/items/water_bottle.png"), 0, 0, false)
	item_stats[id] = item
	inventory[type][id] = 1
	id += 1
	item = Item.new()
	item.init(id, type, preload("res://assets/gfx/items/keg_o_water.png"), 0, 0, false)
	item_stats[id] = item
	inventory[type][id] = 1


func get_all_ids_of_type(type) -> Array:
	return inventory[type].keys() if type in inventory else []


func get_item_amount(type, id) -> int:
	if type in inventory.keys() and id in inventory[type].keys():
		return inventory[type][id]
	return -1


func use_item(type, item_id):
	if type in inventory and item_id in inventory[type] and inventory[type][item_id] > 0 and item_stats[item_id].usable:
		inventory[type][item_id] -= 1
		EventManager.emit_signal("item_used", item_stats[item_id])

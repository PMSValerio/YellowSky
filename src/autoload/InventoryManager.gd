extends Node


var ItemIds = [] # alternative to Items enum, still testing

var item_stats = {}

var _compact_resource_items = {} # ids of all compact resource items organised by value
								# {<resource type>: {
								#	<stat>: <id> } }

var inventory = {}


func _ready():
	# TMP flavour text
	var tmp_flavour = "Hello, this is a placeholder text. I realise this text isn't very helpful, but such is life. That's why it's called placeholder, you doofus."
	
	for t in Global.Items.values(): # have a dictionary for each item type
		inventory[t] = {}
	_compact_resource_items[Global.FacilityResources.WATER] = {}
	_compact_resource_items[Global.FacilityResources.ENERGY] = {}
	_compact_resource_items[Global.FacilityResources.MATERIALS] = {}
	
	# TODO: load item data from config files
	var type = Global.Items.FOOD
	var id = 0
	var item = Item.new()
	item.init(id, type, preload("res://assets/gfx/items/keg_o_water.png"), 5, 10, true)
	item.init_flavour("Test0", tmp_flavour)
	item_stats[id] = item
	inventory[type][id] = 3
	id += 1
	item = Item.new()
	item.init(id, type, preload("res://assets/gfx/items/gallon_of_water.png"), 10, 15, true)
	item.init_flavour("Test1", tmp_flavour)
	item_stats[id] = item
	inventory[type][id] = 5
	id += 1
	item = Item.new()
	item.init(id, type, preload("res://assets/gfx/items/water_bottle.png"), 15, 20, true)
	item.init_flavour("Test2", tmp_flavour)
	item_stats[id] = item
	inventory[type][id] = 1
	
	type = Global.Items.LUXURY
	id += 1
	item = Item.new()
	item.init(id, type, preload("res://assets/gfx/items/gallon_of_water.png"), 30, 0, true)
	item.init_flavour("Test3", tmp_flavour)
	item_stats[id] = item
	inventory[type][id] = 4
	
	type = Global.Items.QUEST
	id += 1
	item = Item.new()
	item.init(id, type, preload("res://assets/gfx/items/water_bottle.png"), 0, 0, false)
	item.init_flavour("Test4", tmp_flavour)
	item_stats[id] = item
	inventory[type][id] = 1
	id += 1
	item = Item.new()
	item.init(id, type, preload("res://assets/gfx/items/keg_o_water.png"), 0, 0, false)
	item.init_flavour("Test5", tmp_flavour)
	item_stats[id] = item
	inventory[type][id] = 1
	
	# ---
	
	type = Global.Items.RESOURCES
	id += 1
	item = Item.new()
	item.init(id, type, preload("res://assets/gfx/items/water_bottle.png"), 5, 10, true)
	item.init_flavour("Water Bottle", tmp_flavour)
	item.subtype = Global.FacilityResources.WATER
	item_stats[id] = item
	_compact_resource_items[item.subtype][item.stat] = id
	inventory[type][id] = 1


# populate inventory data from config files
func _build_items():
	pass


# returns all item_ids of a certain category present in inventory
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


func add_item(type, item_id):
	if type in inventory:
		inventory[type][item_id] = 1 if not item_id in inventory[type] else inventory[type][item_id] + 1

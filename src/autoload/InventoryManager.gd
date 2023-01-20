extends Node


var ItemIds = [] # alternative to Items enum, still testing

var item_stats = {}

var compact_resource_items = {} # ids of all compact resource items organised by value
								# {<resource type>: [item_id] }

var inventory = {}


func _ready():
	# TMP flavour text
	var _tmp_flavour = "Hello, this is a placeholder text. I realise this text isn't very helpful, but such is life. That's why it's called placeholder, you doofus."
	
	for t in Global.Items.values(): # have a dictionary for each item type
		inventory[t] = {}
	compact_resource_items[Global.Resources.WATER] = []
	compact_resource_items[Global.Resources.ENERGY] = []
	compact_resource_items[Global.Resources.MATERIALS] = []
	
	_build_items()


# build a single item from data
func _build_single_item(data):
	var item = Item.new()
	var type = Global.Items[data["type"]]
	var texture = Global.BASE_CONFIG_ASSETS_PATH + data["texture"]
	item.init(data["item_id"], type, texture, data["value"], data["stat"], data["usable"])
	item.init_flavour(data["name"], data["flavour_text"])
	if type == Global.Items.RESOURCES:
		item.subtype = Global.Resources[data["subtype"]]
	return item


# build a category of items
func _build_item_category(file, resources = false):
	var file_data = Global.get_text_from_file(Global.Text.ITEMS, file, [])
	for i in file_data.keys():
		var item : Item = _build_single_item(file_data[i])
		item_stats[item.id] = item
		if resources:
			compact_resource_items[item.subtype].append(item.id)
		inventory[item.type][item.id] = 0


# populate inventory data from config files
func _build_items():
	var config_file = "resources.json"
	_build_item_category(config_file, true)
	config_file = "food.json"
	_build_item_category(config_file)
	config_file = "quests.json"
	_build_item_category(config_file)
	
	# TODO: remove
	for k in inventory[Global.Items.FOOD].keys():
		inventory[Global.Items.FOOD][k] = 5


# returns all item_ids of a certain category present in inventory
func get_all_ids_of_type(type) -> Array:
	return inventory[type].keys() if type in inventory else []


func get_all_compact_ids(resource_type) -> Array:
	return compact_resource_items[resource_type] if resource_type in compact_resource_items else []


func get_item_amount(type, id) -> int:
	if type in inventory.keys() and id in inventory[type].keys():
		return inventory[type][id]
	return -1


func use_item(type, item_id):
	if type in inventory and item_id in inventory[type] and inventory[type][item_id] > 0 and item_stats[item_id].usable:
		inventory[type][item_id] -= 1
		EventManager.emit_signal("item_used", item_stats[item_id])


func _change_item(type, item_id, amount):
	if type in inventory:
		inventory[type][item_id] = 1 if not item_id in inventory[type] else inventory[type][item_id] + amount


func add_item(type, item_id, amount = 1):
	_change_item(type, item_id, amount)


func remove_item(type, item_id, amount = 1):
	_change_item(type, item_id, -amount)

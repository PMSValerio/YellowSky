extends Node


var item_stats = {} # populated with custom item class instances for each item, for easy access
var inventory_layouts = {} # same logic, but for premade inventories

var inventory : Inventory = null
var compact_resource_items = {} # ids of all compact resource items organised by value
								# {<resource type>: [item_id] }


# --- || Ready || ---


func _ready():
	# have an array for each compactable item type
	compact_resource_items[Global.Resources.WATER] = []
	compact_resource_items[Global.Resources.ENERGY] = []
	compact_resource_items[Global.Resources.MATERIALS] = []
	
	_build_items()
	inventory_layouts = Global.get_text_from_file(Global.Text.ITEMS, "inventories.json", [])

	inventory = Inventory.new()
	inventory.init("inventory1")


# --- || Build Funcs || ---


# populate inventory data from config files
func _build_items():
	var config_file = "resources.json"
	_build_item_category(config_file, true)
	config_file = "food.json"
	_build_item_category(config_file)
	config_file = "quests.json"
	_build_item_category(config_file)
	config_file = "luxuries.json"
	_build_item_category(config_file)
	

# build a category of items
func _build_item_category(file, resources = false):

	var file_data = Global.get_text_from_file(Global.Text.ITEMS, file, [])

	for i in file_data.keys():
		var item : Item = _build_single_item(file_data[i])
		item_stats[item.id] = item

		if resources:
			compact_resource_items[item.subtype].append(item.id)


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


# --- || Utility Funcs || ---


func get_all_compact_ids(resource_type) -> Array:
	return compact_resource_items[resource_type] if resource_type in compact_resource_items else []

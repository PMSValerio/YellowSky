extends Node


var item_stats = {} # populated with custom item class instances for each item, for easy access
var inventory_layouts = {} # same logic, but for premade inventories

var inventory : Inventory = null
var compact_resource_items = {} # ids of all compact resource items organised by value
								# {<resource type>: [item_id] }

var cannery_foods = []
var hydro_foods = []
var spoilt_food_id = ""


# --- || Ready || ---


func _ready():
	# have an array for each compactable item type
	compact_resource_items[Global.Resources.WATER] = []
	compact_resource_items[Global.Resources.ENERGY] = []
	compact_resource_items[Global.Resources.MATERIALS] = []
	
	_build_items()
	inventory_layouts = Global.get_text_from_file(Global.Text.ITEMS, "inventories.json", [])

	inventory = Inventory.new()
	inventory.init()


# --- || Build Funcs || ---


# populate inventory data from config files
func _build_items():
	var config_file = "resources.json"
	_build_item_category(config_file, Global.Items.RESOURCES)
	config_file = "food.json"
	_build_item_category(config_file, Global.Items.FOOD)
	config_file = "quests.json"
	_build_item_category(config_file)
	config_file = "luxuries.json"
	_build_item_category(config_file)
	

# build a category of items
func _build_item_category(file, t = -1):

	var file_data = Global.get_text_from_file(Global.Text.ITEMS, file, [])

	for i in file_data.keys():
		var item : Item = _build_single_item(file_data[i])
		item_stats[item.id] = item

		if t == Global.Items.RESOURCES:
			compact_resource_items[item.subtype].append(item.id)
		elif t == Global.Items.FOOD:
			if item.subtype == Global.FacilityTypes.CANNERY:
				cannery_foods.append(item.id)
			elif item.subtype == Global.FacilityTypes.HYDROPONICS:
				hydro_foods.append(item.id)


# build a single item from data
func _build_single_item(data):
	var item = Item.new()
	var type = Global.Items[data["type"]]
	var texture = Global.BASE_CONFIG_ASSETS_PATH + data["texture"]
	item.init(data["item_id"], type, texture, data["value"], data["stat"], data["usable"])
	item.init_flavour(data["name"], data["flavour_text"])

	if type == Global.Items.RESOURCES:
		item.subtype = Global.Resources[data["subtype"]]
	elif type == Global.Items.FOOD:
		if data["subtype"] in Global.FacilityTypes:
			item.subtype = Global.FacilityTypes[data["subtype"]]

	return item


# --- || Utility Funcs || ---


func get_all_compact_ids(resource_type) -> Array:
	return compact_resource_items[resource_type] if resource_type in compact_resource_items else []


# to be used by facilities
func add_food_amount(amount, fac_type) -> void:
	var source = []
	match fac_type:
		Global.FacilityTypes.CANNERY:
			source = cannery_foods
		Global.FacilityTypes.HYDROPONICS:
			source = hydro_foods
	while amount > 0:
		var ix = randi() % source.size()
		var item = item_stats[source[ix]] as Item
		amount -= item.stat
		inventory.add_items(item.type, item.id, 1)


# replace on random food item with a rotten food
func rot_food() -> void:
	var food_items = inventory.get_all_ids_of_type(Global.Items.FOOD).duplicate()
	if food_items.size() > 0:
		food_items.erase(spoilt_food_id)
		var r = randi() % food_items.size()
		inventory.add_items(Global.Items.FOOD, food_items[r], -1)
		inventory.add_items(Global.Items.FOOD, spoilt_food_id, 1)

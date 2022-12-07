extends Node


var tooltip = preload("res://src/gui/menus/resusable/MenuTooltip.tscn")

enum Menus {
	TEST,
	SUBTEST,
	PAUSE_SCREEN,
	FACILITY_MENU,
	MAIN_MENU,
	SETTLEMENT_SCREEN,
	SETTLEMENT_DIALOGUE_SCREEN,
}

enum Disasters {
	TEST,
	AMOGEDDON,
}

enum FacilityTypes {
	WRECKED, # only used for unitialised facilities
	
	# food
	
	# water
	# GROUNDWATER_PUMP,
	# ???
	
	# energy
	COAL_PLANT,
	# EOLIC_TURBINE,
	
	# materials
	PARTS_WORKSHOP, # what a crappy name
	# RECYLING CENTER,
}

# all product types that can be produced by facilities
enum FacilityResources {
	NONE, # just for wrecked probably
	FOOD,
	WATER,
	MATERIALS,
	ENERGY,
	SEEDS, # this should be removed
}

enum Items {
	RESOURCES,
	FOOD,
	LUXURY,
	QUEST,
}

# used to sort out different types of text, as in, item description, settlement descriptions, etc
enum Text {
	ITEMS,
	FACILITIES ,
	SETTLEMENTS,
	NPCS
}

var resource_icons = {
	FacilityResources.NONE: null,
	FacilityResources.FOOD: preload("res://assets/gfx/HUD/waterIcon.png"),
	FacilityResources.WATER: preload("res://assets/gfx/HUD/waterIcon.png"),
	FacilityResources.ENERGY: preload("res://assets/gfx/HUD/energyIcon.png"),
	FacilityResources.MATERIALS: preload("res://assets/gfx/HUD/craftMatIcons.png")
}

var resource_names = {
	FacilityResources.NONE: "<NONE>",
	FacilityResources.FOOD: "Food",
	FacilityResources.WATER: "Water",
	FacilityResources.ENERGY: "Energy",
	FacilityResources.MATERIALS: "Materials",
}

const UPDATE_FREQ = 1.0 # (sec) facilities, settlements, ... update their state every update tick

var facility_types = {} # this file is a horrible place to be doing this

var _cam = null setget set_cam, get_cam
var _screen_size = Vector2.ZERO
var _player = null setget set_player, get_player

var _config_parser : TextManager


func _ready():
	_config_parser = TextManager.new()
	
	_screen_size = get_viewport().get_visible_rect().size
	_init_facility_types()


func set_cam(cam : Camera2D):
	_cam = cam


func get_cam() -> Camera2D:
	return _cam


func get_screen_size() -> Vector2:
	return _screen_size


func set_player(player):
	_player = player


func get_player():
	return _player


# in case further customizations are to be made to tooltip
func get_tooltip():
	return tooltip.instance()


func get_text_from_file(text_type, file_name, key_array):
	return _config_parser.get_text_from_file(text_type, file_name, key_array)


func _build_single_facility(data):
	var facility = FacilityType.new()
	var type = FacilityTypes[data["type_id"]]
	var fuel_types = []
	for str_f in data["fuel_types"]:
		fuel_types.append(FacilityResources[str_f])
	var prod_types = []
	for str_p in data["product_types"]:
		prod_types.append(FacilityResources[str_p])
	facility.init(type, data["type_name"], data["flavour_text"], fuel_types, prod_types, data["base_animation"], data["portrait_texture"], data["icon_texture"])
	facility.init_stats(data["max_health"], data["max_fuel"], data["max_product"], data["consumption_rate"], data["production_rate"])
	return facility


func _init_facility_types():
	var config_file = "base_facilities.json"
	var file_data = _config_parser.get_text_from_file(Text.FACILITIES, config_file, [])
	for fac_type in file_data.keys():
		var facility = _build_single_facility(file_data[fac_type])
		facility_types[facility.type_id] = facility

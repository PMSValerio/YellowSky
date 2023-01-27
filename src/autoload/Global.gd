extends Node


var menu_tooltip = preload("res://src/gui/menus/reusable/MenuTooltip.tscn")
var grid_slot_tooltip = preload("res://src/gui/menus/reusable/GridSlotTooltip.tscn")
var default_cursor = preload("res://assets/gfx/ui_elements/pointer.png")
var pan_cursor = preload("res://assets/gfx/ui_elements/pan_pointer.png")
var event_scene = preload("res://src/map/feature/event/Event.tscn")


enum Menus {
	TEST,
	SUBTEST,
	PAUSE_SCREEN,
	FACILITY_MENU,
	MAIN_MENU,
	SETTLEMENT_SCREEN,
	TRADE_SCREEN,
	EVENT_SCREEN,
	EVENT_REQUIREMENTS_SCREEN,
}

enum Warnings {
	MSQ,
	F_DAMAGE,
	S_DAMAGE,
	F_CRITICAL,
	S_CRITICAL,
	QUEST,
	NO_FUEL,
	FULL,
}

enum Disasters {
	TEST,
	TORNADO,
	STORM,
	RAIN,
	AMOGEDDON,
}

enum Resources {
	NONE,
	WATER, 
	MATERIALS,
	ENERGY,
	FOOD, # Maybe? 
	SEEDS,
	HOPE,
}

enum FacilityTypes {
	WRECKED, # only used for unitialised facilities
	
	# food
	CANNERY,
	HYDROPONICS
	
	# water
	WATER_PUMP,
	PURIFIER
	
	# energy
	COAL_PLANT,
	WIND_FARM,
	
	# materials
	PARTS_WORKSHOP, # what a crappy name
	RECYCLER,
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
	NPCS,
	QUESTS,
	EVENTS,
}

# types of events
enum EventTypes {
	GENERIC,
	QUEST,
}

# using "FacilityResources" instead of Resources? Doubt. Not sure on best course of action.
var resource_icons = {
	Resources.NONE: null,
	Resources.WATER: preload("res://assets/gfx/ui_elements/icons/waterIcon.png"),
	Resources.MATERIALS: preload("res://assets/gfx/ui_elements/icons/craftMatIcons.png"),
	Resources.ENERGY: preload("res://assets/gfx/ui_elements/icons/energyIcon.png"),
	Resources.FOOD: preload("res://assets/gfx/HUD/HUD_icons/icon_stamina.png"),
	Resources.SEEDS: preload("res://assets/gfx/ui_elements/icons/seedsIcon.png"),
}

var resource_names = {
	Resources.NONE: "<NONE>",
	Resources.WATER: "Water",
	Resources.MATERIALS: "Materials",
	Resources.ENERGY: "Energy",
	Resources.FOOD: "Food",
}

var item_category_names = {
	Items.RESOURCES: "Resources",
	Items.FOOD: "Food",
	Items.LUXURY: "Luxury",
	Items.QUEST: "Quest",
}

const COMPACT_LOSS = 1.2

const UPDATE_FREQ = 1.0 # (sec) facilities, settlements, ... update their state every update tick
const DAY_DURATION = 600 # duration of a day in seconds
const NIGHT_THRESHOLD = 30 # duration of nightfall animation in seconds

const BASE_CONFIG_ASSETS_PATH = "res://assets/gfx/config_assets/"

var facility_types = {} # this file is a horrible place to be doing this

var _cam = null setget set_cam, get_cam
var _screen_size = Vector2.ZERO
var _player = null setget set_player, get_player
var _warped_mouse_pos = Vector2.ZERO

var _config_parser : TextManager


func _ready():
	randomize()
	
	_config_parser = TextManager.new()
	
	_screen_size = get_viewport().get_visible_rect().size
	_init_facility_types()


func set_cam(cam : Camera2D):
	_cam = cam


func get_cam() -> Camera2D:
	return _cam

func change_mouse_cursor(is_pan : bool):
	if is_pan:
		Input.set_custom_mouse_cursor(pan_cursor)
	else:
		Input.set_custom_mouse_cursor(default_cursor)

func get_screen_size() -> Vector2:
	return _screen_size


func set_player(player):
	_player = player


func get_player():
	return _player


func set_mouse_in_perspective(mouse_pos : Vector2):
	_warped_mouse_pos = mouse_pos


func get_mouse_in_perspective() -> Vector2:
	return _warped_mouse_pos


# in case further customizations are to be made to tooltip
func get_tooltip():
	return menu_tooltip.instance()


func get_text_from_file(text_type, file_name, key_array):
	return _config_parser.get_text_from_file(text_type, file_name, key_array)


func _build_single_facility(data):
	var facility = FacilityType.new()
	var type = FacilityTypes[data["type_id"]]
	var fuel_types = []
	for str_f in data["fuel_types"]:
		fuel_types.append(Resources[str_f])
	var prod_types = []
	var portrait = BASE_CONFIG_ASSETS_PATH + data["portrait_texture"]
	var icon = BASE_CONFIG_ASSETS_PATH + data["icon_texture"]
	for str_p in data["product_types"]:
		prod_types.append(Resources[str_p])
	facility.init(type, data["type_name"], data["flavour_text"], fuel_types, prod_types, data["base_animation"], portrait, icon)
	facility.init_stats(data["build_cost"], data["max_health"], data["max_fuel"], data["max_product"], data["consumption_rate"], data["production_rate"])
	return facility


func _init_facility_types():
	var config_file = "base_facilities.json"
	var file_data = _config_parser.get_text_from_file(Text.FACILITIES, config_file, [])
	for fac_type in file_data.keys():
		var facility = _build_single_facility(file_data[fac_type])
		facility_types[facility.type_id] = facility


func get_event_data(event_id, type) -> EventData:
	var filepath = "generic.json"
	match type:
		EventTypes.QUEST:
			filepath = "quests.json"
		EventTypes.GENERIC:
			filepath = "generic.json"
	var event = EventData.new()
	var data = get_text_from_file(Text.EVENTS, filepath, [event_id])
	event.init(event_id, type, data["animation"], data["title"], data["flavour_text"], data["item_updates"])
	return event


func get_quest_data(quest_id) -> Quest:
	var quest = Quest.new()
	var data = get_text_from_file(Global.Text.QUESTS, "quests.json", [quest_id])
	
	quest.init(quest_id, data)
	return quest


func generate_event(event_data : EventData, cell_position : Vector2 = Vector2(-1, -1), die_on_interact = true, send_signal = true):
	var event = event_scene.instance()
	
	event.cell_pos = cell_position
	event.die_on_interact = die_on_interact
	event.set_data(event_data)
	
	if send_signal:
		EventManager.emit_signal("spawn_event_request", event)
	
	return event

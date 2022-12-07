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

var _custom_tooltip = null


func _ready():
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


func _init_facility_types():
	var placeholder_text = "This is a placeholder text that is currently set to all facilities. Later on, it will give a nice little piece of background for each type. Now won't that be nice."
	var placeholder_art = preload("res://assets/gfx/menus/facility_portrait_tmp.png")
	
	var facility = FacilityType.new() # wrecked facility
	var tex = preload("res://assets/gfx/menus/facility_icon/wrecked_icon.png")
	facility.init(FacilityTypes.WRECKED, "Abandoned Facility", placeholder_text, [], [], "wrecked", preload("res://assets/gfx/menus/fac_wrecked.png"), tex)
	facility.init_stats(0.0, 0.0, 0.0, 0.0, 0.0)
	facility_types[FacilityTypes.WRECKED] = facility
	
	facility = FacilityType.new() # coal plant
	tex = preload("res://assets/gfx/menus/facility_icon/coal_plant_icon.png")
	facility.init(FacilityTypes.COAL_PLANT, "Coal Plant", placeholder_text, [], [FacilityResources.ENERGY], "coal_plant", placeholder_art, tex)
	facility.init_stats(100.0, 100.0, 100.0, 2.0, 5.0)
	facility_types[FacilityTypes.COAL_PLANT] = facility
	
	facility = FacilityType.new() # parts workshop
	facility.init(FacilityTypes.PARTS_WORKSHOP, "Parts Workshop", placeholder_text, [FacilityResources.ENERGY], [FacilityResources.MATERIALS], "coal_plant", placeholder_art, tex)
	facility.init_stats(100.0, 100.0, 100.0, 2.0, 5.0)
	facility_types[FacilityTypes.PARTS_WORKSHOP] = facility

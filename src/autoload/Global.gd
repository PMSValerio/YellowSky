extends Node


enum Menus {
	TEST,
	SUBTEST,
	CHOOSE_FACILITY,
	FACILITY_SCREEN,
	INVENTORY_SCREEN,
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

# THIS NEEDS TO DISAPPEAR
# USE FacilityResources INSTEAD
enum Resources {
	WATER,
	MATERIALS,
	ENERGY,
	SEEDS,
}

enum Items {
	RESOURCES,
	FOOD,
	LUXURY,
	QUEST,
}

const UPDATE_FREQ = 1.0 # (sec) facilities, settlements, ... update their state every update tick

var facility_types = {} # this file is a horrible place to be doing this

var _cam = null setget set_cam, get_cam
var _screen_size = Vector2.ZERO
var _player = null setget set_player, get_player


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


func _init_facility_types():
	var placeholder_text = "This is a placeholder text that is currently set to all facilities. Later on, it will give a nice little piece of background for each type. Now won't that be nice."
	var placeholder_art = preload("res://assets/gfx/menus/facility_portrait_tmp.png")
	
	var facility = FacilityType.new() # wrecked facility
	facility.init(FacilityTypes.WRECKED, "Abandoned Facility", placeholder_text, FacilityResources.NONE, [], "wrecked", placeholder_art, 0.0, 0.0)
	facility_types[FacilityTypes.WRECKED] = facility
	
	facility = FacilityType.new() # coal plant
	facility.init(FacilityTypes.COAL_PLANT, "Coal Plant", placeholder_text, FacilityResources.ENERGY, [], "coal_plant", placeholder_art, 5.0, 2.0)
	facility_types[FacilityTypes.COAL_PLANT] = facility
	
	facility = FacilityType.new() # parts workshop
	facility.init(FacilityTypes.PARTS_WORKSHOP, "Parts Workshop", placeholder_text, FacilityResources.MATERIALS, [FacilityResources.ENERGY], "coal_plant", placeholder_art, 5.0, 2.0)
	facility_types[FacilityTypes.PARTS_WORKSHOP] = facility

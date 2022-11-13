extends Node


enum Menus {
	TEST,
	SUBTEST,
	CHOOSE_FACILITY,
	FACILITY_SCREEN,
}

enum Disasters {
	TEST,
}

# all facility types
enum Resources {
	FOOD, # kinda wrong being here, but is also a possible facility product
	WATER,
	MATERIALS,
	ENERGY,
	SEEDS,
}

const UPDATE_FREQ = 1.0 # (sec) facilities, settlements, ... update their state every update tick

var _cam = null setget set_cam, get_cam
var _screen_size = Vector2.ZERO
var _player = null setget set_player, get_player


func _ready():
	_screen_size = get_viewport().get_visible_rect().size 


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

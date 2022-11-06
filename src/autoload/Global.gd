extends Node


enum Menus {
	TEST,
	SUBTEST,
}

enum Disasters {
	TEST,
}


var _cam = null
var _ref_tilemap = null
var _screen_size = Vector2.ZERO


func _ready():
	_screen_size = get_viewport().get_visible_rect().size 


func set_cam(cam : Camera2D):
	_cam = cam


func get_cam() -> Camera2D:
	return _cam


func get_screen_size() -> Vector2:
	return _screen_size

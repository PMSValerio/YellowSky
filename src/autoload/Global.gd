extends Node


var _cam = null
var _ref_tilemap = null


func set_cam(cam : Camera2D):
	_cam = cam


func get_cam() -> Camera2D:
	return _cam

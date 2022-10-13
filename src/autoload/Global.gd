extends Node


var _cam = null
var _ref_tilemap = null


func set_cam(cam : Camera2D):
	_cam = cam


func get_cam() -> Camera2D:
	return _cam


func set_ref_tilemap(ref_tilemap : TileMap):
	_ref_tilemap = ref_tilemap


func get_ref_tilemap() -> TileMap:
	return _ref_tilemap

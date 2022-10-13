extends Sprite
class_name PerspectiveSprite

export var HORIZON_Y = 0.7
export var STRETCH_FACTOR = 0.4

export (NodePath) var PROXY

var a = 1.0
var b = STRETCH_FACTOR
var h = HORIZON_Y


func _physics_process(_delta: float) -> void:
	var tilemap = Global.get_ref_tilemap()
	var screen_pos = tilemap.get_viewport_transform() * (tilemap.get_global_transform() * get_parent().global_position)
	screen_pos.x /= tilemap.get_viewport_rect().size.x
	screen_pos.y = 1.0 - (screen_pos.y / tilemap.get_viewport_rect().size.y)
	
	var bb = 1.0 / b
	var q = (bb - a) / 2.0
	
	var p = (bb * h) / (bb - a)
	
	var yy = screen_pos.y * bb * h
	yy = yy / (a * h + screen_pos.y * (bb - a))
	
	var w = (screen_pos.x * (p - yy)) / (p - h)
	
	var d = (q * (h - yy)) / h
	
	screen_pos.x = w - d
	screen_pos.y = yy
	
	screen_pos.x *= tilemap.get_viewport_rect().size.x
	screen_pos.y = (1.0 - screen_pos.y) * tilemap.get_viewport_rect().size.y
	
	var pos = tilemap.get_global_transform().affine_inverse() * (tilemap.get_viewport_transform().affine_inverse() * screen_pos)
	
	global_position = pos
	var scl = (1.0 - yy) * 3.0
	global_scale = Vector2(scl, scl)
	
	if yy <= h:
		visible = true
	else:
		visible = false

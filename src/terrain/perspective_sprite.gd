extends Sprite


export var HORIZON_Y = 0.7
export var STRETCH_FACTOR = 0.4

export (NodePath) var PROXY

var a = 1.0
var b = STRETCH_FACTOR
var h = HORIZON_Y


func _physics_process(delta: float) -> void:
	var tilemap = Global.get_ref_tilemap()
	var screen_pos = tilemap.get_viewport_transform() * (tilemap.get_global_transform() * get_parent().global_position)
	screen_pos.x /= tilemap.get_viewport_rect().size.x
	screen_pos.y = 1.0 - (screen_pos.y / tilemap.get_viewport_rect().size.y)
	
	print(screen_pos)

	var p = (a * h) / (a - b)

	var yy = screen_pos.y * a * h
	yy = yy / (b * h + screen_pos.y * (a - b))

	var xx = (screen_pos.x / p) * (p - yy)

	var d = (a * yy) / (2.0 * p)

	screen_pos.x = d + xx
	screen_pos.y = yy
	
	print(screen_pos)
	print("---")
	
	screen_pos.x *= tilemap.get_viewport_rect().size.x
	screen_pos.y = (1.0 - screen_pos.y) * tilemap.get_viewport_rect().size.y
	
	var pos = tilemap.get_global_transform().affine_inverse() * (tilemap.get_viewport_transform().affine_inverse() * screen_pos)
	
	global_position = pos

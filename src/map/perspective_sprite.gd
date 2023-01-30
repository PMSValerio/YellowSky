extends Sprite
class_name PerspectiveSprite

export var BASE_SCALE = 1.0
export var UPDATE_Z = false

onready var _last_true_pos = Vector2(-1, -1)

var a = 1.0
var b = 0.7
var h = 0.4

var _yy = 0.0


func _ready() -> void:
	b = MapUtils.STRETCH_FACTOR
	h = MapUtils.HORIZON_Y
	if UPDATE_Z:
		z_as_relative = false


func _physics_process(_delta: float) -> void:
	if MapUtils.is_enabled() == true:
		_perspective_poise()
		_perspective_colour()
	if UPDATE_Z:
		if get_parent().global_position != _last_true_pos:
			var hex_cell = MapUtils.get_ref_tilemap().world_to_map(MapUtils.get_hex_center(get_parent().global_position))
			z_index = -(MapUtils.row_count - hex_cell.y)
	_last_true_pos = get_parent().global_position


# warp position and scale in accordance with perspective parameters
func _perspective_poise():
	var tilemap = MapUtils.get_ref_tilemap()
	var screen_size = get_viewport_transform() * tilemap.get_viewport_rect().size # transforms the real port size with the current viewport transform
	
	var screen_pos = tilemap.get_viewport_transform() * (tilemap.get_global_transform() * get_parent().global_position)
	screen_pos.x /= screen_size.x
	screen_pos.y = 1.0 - (screen_pos.y / screen_size.y)
	
	var bb = 1.0 / b
	var q = (bb - a) / 2.0
	
	var p = (bb * h) / (bb - a)
	
	var yy = screen_pos.y * bb * h
	yy = yy / (a * h + screen_pos.y * (bb - a))
	
	var w = (screen_pos.x * (p - yy)) / (p - h)
	
	var d = (q * (h - yy)) / h
	
	screen_pos.x = w - d
	screen_pos.y = yy
	_yy = yy
	
	screen_pos.x *= screen_size.x
	screen_pos.y = (1.0 - screen_pos.y) * screen_size.y
	
	var pos = tilemap.get_global_transform().affine_inverse() * (tilemap.get_viewport_transform().affine_inverse() * screen_pos)
	
	var scl = (1.0 - clamp(yy, -0.5, 1.5)) * BASE_SCALE
	global_position = pos
	global_scale = Vector2(scl, scl)
	
	if yy <= h:
		visible = true
	else:
		visible = false


# alter shader parameters to dim and/or fade texture
func _perspective_colour():
	if material:
		material.set_shader_param("height", _yy)

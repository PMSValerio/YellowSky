extends Node

const HORIZON_Y = 0.7
const STRETCH_FACTOR = 0.4

var screen_wid = 1024
var screen_hei = 600

# dimensions of the corresponding rectangular cells
var cell_wid = 56.0
var cell_hei = 48.0

# x of hex tile center
var mid_wid = cell_wid / 2.0
# cell height / 4
var quarter_hei = cell_hei / 4.0

# the top edges vectors in cell local coords
var edge_right = Vector2(cell_wid, quarter_hei) - Vector2(mid_wid, 0.0)
var edge_left = Vector2(mid_wid, 0.0) - Vector2(0.0, quarter_hei)

var row_count = -1
var col_count = -1

# enables perpective warps
const ENABLED = true

var _ref_tilemap : TileMap = null


func _ready() -> void:
	screen_wid = OS.window_size.x
	screen_hei = OS.window_size.y


# set the tilemap to be used for map calculations
func set_ref_tilemap(ref_tilemap : TileMap) -> void:
	_ref_tilemap = ref_tilemap
	cell_wid = _ref_tilemap.cell_size.x
	cell_hei = _ref_tilemap.cell_size.y
	mid_wid = cell_wid / 2.0
	quarter_hei = cell_hei / 4.0
	edge_right = Vector2(cell_wid, quarter_hei) - Vector2(mid_wid, 0.0)
	edge_left = Vector2(mid_wid, 0.0) - Vector2(0.0, quarter_hei)


# set the number of rows and cells to be used
func set_dimensions(rows, columns):
	row_count = rows
	col_count = columns


# return reference tilemap
func get_ref_tilemap() -> TileMap:
	return _ref_tilemap


# perspective warp effects should be enabled
func is_enabled() -> bool:
	return ENABLED

# get the hexagon center position of the hexagon that pos (a global position) is inside of
func get_hex_center(pos : Vector2) -> Vector2:
	pos.x = round(pos.x)
	pos.y = round(pos.y)
	var cell = _ref_tilemap.world_to_map(_ref_tilemap.to_local(pos))
	var odd_row = int(cell.y) % 2 != 0
	var offset = 0.0
	var not_offset = mid_wid
	if odd_row:
		offset = mid_wid
		not_offset = 0.0
	pos.x -= offset
	
	var pos_in_cell = Vector2(fmod(pos.x, cell_wid), fmod(pos.y, cell_hei))
	if pos_in_cell.x < 0:
		pos_in_cell.x += cell_wid
	if pos_in_cell.y < 0:
		pos_in_cell.y += cell_hei
	
	if pos_in_cell.y < quarter_hei:
		if pos_in_cell.x <= mid_wid:
			var vec = pos_in_cell - Vector2(0.0, quarter_hei)
			if edge_left.cross(vec) < 0:
				if not odd_row:
					cell.x -= 1
				cell.y -= 1
				offset = not_offset
		else:
			var vec = pos_in_cell - Vector2(mid_wid, 0.0)
			if edge_right.cross(vec) < 0:
				if odd_row:
					cell.x += 1
				cell.y -= 1
				offset = not_offset
	
	var hex_center = Vector2(offset + cell.x * cell_wid + cell_wid / 2, cell.y * cell_hei + cell_hei * (2.0/3.0))
	
	return hex_center


func get_hex_id(pos : Vector2) -> int:
	pos.x = round(pos.x)
	pos.y = round(pos.y)
	var cell = _ref_tilemap.world_to_map(_ref_tilemap.to_local(pos))
	return _ref_tilemap.get_cell(cell.x, cell.y)


# transform mouse screen position to unwarped world position
# this wall of math performs the exact opposite operation done in perspective_sprite and for figuring that out I deserve a medal
func get_warped_mouse_position() -> Vector2:
	var b = STRETCH_FACTOR
	var h = HORIZON_Y
	var a = 1.0
	var screen_pos = get_viewport().get_mouse_position()
	var screen_size = Vector2(screen_wid, screen_hei)
	
	screen_pos.x /= screen_size.x
	screen_pos.y = 1.0 - (screen_pos.y / screen_size.y)
	
	var bb = 1.0 / b
	var q = (bb - a) / 2.0

	var p = (bb * h) / (bb - a)
	
	var d = (q * (h - screen_pos.y)) / h
	
	var w = screen_pos.x + d
	
	var xx = (w * (p - h)) / (p - screen_pos.y)
	
	var yy = (a * h * screen_pos.y) / (bb * h - screen_pos.y * (bb - a))
	
	screen_pos.x = xx
	screen_pos.y = yy
	
	screen_pos.x *= screen_size.x
	screen_pos.y = (1.0 - screen_pos.y) * screen_size.y
	
	return screen_pos
	

""" 	
	I hereby award you this medal, for all the math that allows conversions between screen space and
	warped space, significantly contributing to the advancement of the game development scene as a whole:
	_________________
	|@@@@|     |####|
	|@@@@|     |####|
	|@@@@|     |####|
	`@@@@|     |####'
	 `@@@|     |###'
	  `@@|_____|##'
		   (O)
		.-'''''-.
	  .'  * * *  `.
	 :  *       *  :
	: ~ A S C I I ~ :
	: ~ A W A R D ~ :
	 :  *       *  :
	  `.  * * *  .'
		`-.....-' 
"""

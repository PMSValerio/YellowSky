extends Node


const HORIZON_Y = 0.7
const STRETCH_FACTOR = 0.4

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

const ENABLED = true

var _ref_tilemap : TileMap = null


# set the tilemap to be used for map calculations
func set_ref_tilemap(ref_tilemap : TileMap) -> void:
	_ref_tilemap = ref_tilemap
	cell_wid = _ref_tilemap.cell_size.x
	cell_hei = _ref_tilemap.cell_size.y
	mid_wid = cell_wid / 2.0
	quarter_hei = cell_hei / 4.0
	edge_right = Vector2(cell_wid, quarter_hei) - Vector2(mid_wid, 0.0)
	edge_left = Vector2(mid_wid, 0.0) - Vector2(0.0, quarter_hei)


# return reference tilemap
func get_ref_tilemap() -> TileMap:
	return _ref_tilemap


# perspective warp effects should be enabled
func is_enabled() -> bool:
	return ENABLED

# get the hexagon center position of the hexagon that pos (a global position) is inside of
func get_hex_center(pos : Vector2):
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

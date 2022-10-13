extends Node


const CELL_WID = 56.0
const CELL_HEI = 48.0

var mid_wid = CELL_WID / 2.0
var quarter_hei = CELL_HEI / 4.0

# the top edges vectors in cell local coords
var edge_right = Vector2(mid_wid, 0.0) - Vector2(CELL_WID, quarter_hei)
var edge_left = Vector2(mid_wid, 0.0) - Vector2(0.0, quarter_hei)


func _ready() -> void:
	Global.set_cam($Entities/Sprite/Camera2D)
	Global.set_ref_tilemap($TileMap)


func _physics_process(_delta: float) -> void:
	pass
	#var mouse = get_viewport().get_mouse_position()
	
	#$Entities/Sprite.position = get_hex_center(mouse)


# get the hexagon center position of the hexagon that pos is inside of
func get_hex_center(pos : Vector2):
	var celly = int(floor(pos.y / CELL_HEI))
	# offset if row is odd
	var odd_row = celly % 2
	
	var offset = 0.0
	var not_offset = mid_wid
	if odd_row != 0:
		offset = mid_wid
		not_offset = 0.0
	pos.x -= offset
	var cellx = int(floor(pos.x / CELL_WID))
	
	var pos_in_cell = Vector2(fmod(pos.x, CELL_WID), fmod(pos.y, CELL_HEI))
	
	if pos_in_cell.y < quarter_hei:
		var vec = Vector2(mid_wid, 0.0) - pos_in_cell
		if pos_in_cell.x > mid_wid and edge_right.cross(vec) < 0:
			if odd_row:
				cellx += 1
			celly -= 1
			offset = not_offset
		elif pos_in_cell.x <= mid_wid and edge_left.cross(vec) > 0:
			if not odd_row:
				cellx -= 1
			celly -= 1
			offset = not_offset
	
	var hex_center = Vector2(offset + cellx * CELL_WID + CELL_WID / 2, celly * CELL_HEI + CELL_HEI * (2.0/3.0))
	
	return hex_center

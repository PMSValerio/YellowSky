extends Node2D

signal tile_entered(id)

export (PackedScene) var MOUNTAIN_SCENE

onready var map_perspective = $MapEffect
onready var sky = $Sky
onready var entities = $Entities

onready var tilemap = $TileMap
onready var cursor = $Cursor
var cache_hex_center = Vector2.ZERO
var hex_center = Vector2.ZERO

onready var mountains = $Entities/Mountains


var _rng = RandomNumberGenerator.new()


func _ready() -> void:
	Global.set_cam($Entities/Node2D/Camera2D)
	MapUtils.set_ref_tilemap($TileMap)
	
	_rng.randomize()
	_generate_map(_rng.randi())

	hex_center = MapUtils.get_hex_center(_get_cursor_position())
	cache_hex_center = MapUtils.get_hex_center(_get_cursor_position())
	
	if MapUtils.is_enabled():
		sky.visible = true
		map_perspective.visible = true
	else:
		sky.visible = false
		map_perspective.visible = false


func _physics_process(_delta: float) -> void:
	hex_center = MapUtils.get_hex_center(_get_cursor_position())

	if hex_center != cache_hex_center:
		cursor.global_position = hex_center
		cache_hex_center = hex_center
		emit_signal("tile_entered", MapUtils.get_hex_id(hex_center))

	


func _get_cursor_position():
	return $Entities/Node2D.global_position


# generate procedurally generated map
func _generate_map(map_seed):
	var simplex_noise = OpenSimplexNoise.new()
	
	simplex_noise.seed = map_seed
	simplex_noise.octaves = 4
	simplex_noise.period = 20.0
	simplex_noise.persistence = 0.8
	
	var image = simplex_noise.get_image(320, 320)
	image.save_png("user://map.png")
	for cell in tilemap.get_used_cells():
		_noise_map_process_cell(cell, simplex_noise.get_noise_2dv(cell))


# fill map cell according to simplex noise value
func _noise_map_process_cell(cell : Vector2, noise_value : float):
	if noise_value > 0.0 or noise_value < -0.5:
		if MOUNTAIN_SCENE:
			var world_pos = tilemap.map_to_world(cell)
			var mountain = MOUNTAIN_SCENE.instance()
			mountain.global_position = world_pos + Vector2(tilemap.cell_size.x / 2, tilemap.cell_size.y * 2/3)
			mountains.add_child(mountain)

extends Node2D

signal tile_entered(id)

export (PackedScene) var MOUNTAIN_SCENE

onready var map_perspective = $MapEffect
onready var sky = $Sky
onready var entities = $Entities

onready var tilemap = $TileMap
onready var cursor = $Cursor
onready var player = $Entities/Player

var cache_hex_center = Vector2.ZERO
var hex_center = Vector2.ZERO

onready var mountains = $Entities/Mountains

var _rng = RandomNumberGenerator.new()

var map_grid = []


func _ready() -> void:
	MapUtils.set_ref_tilemap($TileMap)
	
	_rng.randomize()
	_generate_map(_rng.randi())

	hex_center = MapUtils.get_hex_center(_get_player_position())
	cache_hex_center = hex_center
	
	if MapUtils.is_enabled():
		sky.visible = true
		map_perspective.visible = true
	else:
		sky.visible = false
		map_perspective.visible = false
	
	var cell = tilemap.world_to_map(MapUtils.get_hex_center($Entities/Feature.global_position))
	map_grid[cell.x][cell.y] = $Entities/Feature


func _physics_process(_delta: float) -> void:
	hex_center = MapUtils.get_hex_center(_get_player_position())

	if hex_center != cache_hex_center:
		cursor.global_position = hex_center
		cache_hex_center = hex_center
		emit_signal("tile_entered", MapUtils.get_hex_id(hex_center))


func _get_player_position():
	return player.global_position


# generate procedurally generated map
func _generate_map(map_seed):
	var simplex_noise = OpenSimplexNoise.new()
	
	simplex_noise.seed = map_seed
	simplex_noise.octaves = 4
	simplex_noise.period = 20.0
	simplex_noise.persistence = 0.8
	
	var image = simplex_noise.get_image(320, 320)
	image.save_png("user://map.png")
	var xx = null
	for cell in tilemap.get_used_cells():
		if not xx or xx != cell.y:
			xx = cell.x
			map_grid.append([])
		_noise_map_process_cell(cell, simplex_noise.get_noise_2dv(cell))


# fill map cell according to simplex noise value
func _noise_map_process_cell(cell : Vector2, noise_value : float):
	# cells MUST form a rectangle and cells MUST start at (0,0), otherwise, it would be a pain in the ass
	map_grid[cell.x].append(0)
	
	if noise_value > 0.0 or noise_value < -0.5:
		if MOUNTAIN_SCENE:
			var world_pos = tilemap.map_to_world(cell)
			var mountain = MOUNTAIN_SCENE.instance()
			mountain.global_position = world_pos + Vector2(tilemap.cell_size.x / 2, tilemap.cell_size.y * 2/3)
			mountains.add_child(mountain)
			map_grid[cell.x][cell.y] = mountain


func _on_Player_interact(position):
	var hex_tile = tilemap.world_to_map(MapUtils.get_hex_center(position))
	
	var tile_entity = map_grid[hex_tile.x][hex_tile.y]
	if tile_entity is Object and tile_entity.has_method("interact"):
		tile_entity.interact()

extends Node2D


# to be used solely on the process of procedural generation
enum TileType{
	EMPTY,
	MOUNTAIN,
	FEATURE, # feature type should never be used at the same time as either settlement or facility, it is merely a temporary type
	SETTLEMENT,
	FACILITY,
}

export (PackedScene) var MOUNTAIN_SCENE

onready var map_perspective = $MapEffect
onready var sky = $Sky
onready var entities = $Entities

onready var tilemap = $TileMap
onready var cursor = $Cursor
onready var player = $Entities/Player
onready var mountains = $Entities/Mountains

var hex_center = Vector2.ZERO
var cache_hex_center = Vector2.ZERO

var _rng = RandomNumberGenerator.new()
var map_grid = []

func _ready() -> void:
	MapUtils.set_ref_tilemap($TileMap)
	_rng.randomize()
	_generate_map()
	MapUtils.set_dimensions(map_grid[0].size(), map_grid.size())

	hex_center = MapUtils.get_hex_center(_get_player_position())
	cache_hex_center = hex_center
	
	if MapUtils.is_enabled():
		sky.visible = true
		map_perspective.visible = true
	else:
		sky.visible = false
		map_perspective.visible = false
	
	# TODO: remove
	var cell = tilemap.world_to_map(MapUtils.get_hex_center($Entities/Feature.global_position))
	map_grid[cell.x][cell.y] = $Entities/Feature
	
	cell = tilemap.world_to_map(MapUtils.get_hex_center($Entities/Facility.global_position))
	map_grid[cell.x][cell.y] = $Entities/Facility

	cell = tilemap.world_to_map(MapUtils.get_hex_center($Entities/Settlement.global_position))
	map_grid[cell.x][cell.y] = $Entities/Settlement


func _physics_process(_delta: float) -> void:
	hex_center = MapUtils.get_hex_center(_get_player_position())
	var hex_tile = tilemap.world_to_map(MapUtils.get_hex_center(hex_center))
	var tile_entity = map_grid[hex_tile.x][hex_tile.y]
	
	if hex_center != cache_hex_center:
		cursor.global_position = hex_center
		cache_hex_center = hex_center
		var interactable = _is_feature(tile_entity)
		player._on_World_tile_entered(interactable)


func _get_player_position():
	return player.global_position


# return whether a tile entity is a feature tile
func _is_feature(tile_entity):
	if tile_entity != null:
		if tile_entity is Feature:
			return true
	return false


# || --- MAP GENERATION --- ||


# map generation pipeline
func _generate_map():
	var used_cells = tilemap.get_used_cells()
	var noise = _noise_generation(_rng.randi(), used_cells)
	_balance_mountain_ratio(used_cells, noise)
	
	# actual process of populating the map with the apropriate scenes
	for cell in used_cells:
		_instance_map_scene(cell, map_grid[cell.x][cell.y])


# generate procedurally generated map, using perlin noise
func _noise_generation(map_seed, used_cells):
	var simplex_noise = OpenSimplexNoise.new()
	
	simplex_noise.seed = map_seed
	simplex_noise.octaves = 4
	simplex_noise.period = 20.0
	simplex_noise.persistence = 0.8
	
#	var image = simplex_noise.get_image(320, 320)
#	image.save_png("user://map.png")
	var xx = null
	for cell in used_cells:
		if not xx or xx != cell.y:
			xx = cell.x
			map_grid.append([])
		# cells MUST form a rectangle and cells MUST start at (0,0), otherwise, it would be a pain in the ass
		map_grid[cell.x].append(0)
	return simplex_noise


# return the corresponding tile type according to the noise value for the cell
func _noise_map_process_cell(cell : Vector2, noise_value : float, mountain_threshold : float):
	var type = TileType.EMPTY
	if -mountain_threshold > noise_value or noise_value > mountain_threshold:
		type = TileType.MOUNTAIN
	map_grid[cell.x][cell.y] = type
	return type


# balance the ratio of mountains on the map
func _balance_mountain_ratio(used_cells, simplex_noise):
	var min_ratio = 0.3
	var max_ratio = 0.4
	var threshold_step = 0.025
	var min_thresh = 0.05
	var max_thresh = 0.5
	var max_tries = 10 # failsafe loop break condition
	
	var mountain_count = 0
	var mountain_ratio = min_ratio - 1 # initialise as if it were too low
	var empty_thresh = 0.175 + threshold_step # this initial value was chosen after some experimentation
	
	var tries = 0
	while tries < max_tries and (not (min_ratio < mountain_ratio and mountain_ratio < max_ratio)) and empty_thresh > min_thresh and empty_thresh < max_thresh:
		if mountain_ratio > max_ratio:
			empty_thresh += threshold_step
		else:
			empty_thresh -= threshold_step
		mountain_count = 0
		
		print("new rebalance with threshold %s" % [empty_thresh])
		
		for cell in used_cells:
			if _noise_map_process_cell(cell, simplex_noise.get_noise_2dv(cell), empty_thresh) == TileType.MOUNTAIN:
				mountain_count += 1
		mountain_ratio = float(mountain_count) / float(used_cells.size())
		tries += 1
		print(mountain_ratio)


# populate with the actual scene instances
func _instance_map_scene(cell : Vector2, scene_type : int):
	var world_pos = tilemap.map_to_world(cell)
	match scene_type:
		TileType.MOUNTAIN:
			if MOUNTAIN_SCENE != null:
				var mountain = MOUNTAIN_SCENE.instance()
				mountain.global_position = world_pos + Vector2(tilemap.cell_size.x / 2, tilemap.cell_size.y * 2/3)
				mountains.add_child(mountain)
				map_grid[cell.x][cell.y] = mountain


# || --- SIGNALS --- ||


# callback function when player presses interact button
func _on_Player_interact(position):
	var hex_tile = tilemap.world_to_map(MapUtils.get_hex_center(position))
	
	var tile_entity = map_grid[hex_tile.x][hex_tile.y]
	if tile_entity is Object and tile_entity.has_method("interact"):
		tile_entity.interact()

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
onready var parallax_sky = $ParallaxSky
onready var entities = $Entities

onready var tilemap = $TileMap
onready var cursor = $Cursor
onready var player = $Entities/Player
onready var mountains = $Entities/Mountains

var hex_center = Vector2.ZERO
var cache_hex_center = Vector2.ZERO
var _mouse_hex_tile = Vector2(-1, -1)

var _rng = RandomNumberGenerator.new()
var map_grid = [] # map grid with references to all game entities

func _ready() -> void:
	MapUtils.set_ref_tilemap($TileMap)
	_rng.randomize()
	_generate_map()
	MapUtils.set_dimensions(map_grid[0].size(), map_grid.size())

	hex_center = MapUtils.get_hex_center(_get_player_position())
	cache_hex_center = hex_center
	
	if MapUtils.is_enabled():
		sky.visible = true
		parallax_sky.visible = true
		map_perspective.visible = true
	else:
		sky.visible = false
		parallax_sky.visible = false
		map_perspective.visible = false
	
	# Manually instance starting features
	var cell = tilemap.world_to_map(MapUtils.get_hex_center($Entities/Feature.global_position))
	map_grid[cell.x][cell.y] = $Entities/Feature
	
	cell = tilemap.world_to_map(MapUtils.get_hex_center($Entities/Facility.global_position))
	map_grid[cell.x][cell.y] = $Entities/Facility

	cell = tilemap.world_to_map(MapUtils.get_hex_center($Entities/Settlement.global_position))
	map_grid[cell.x][cell.y] = $Entities/Settlement


func _physics_process(_delta: float) -> void:
	hex_center = MapUtils.get_hex_center(_get_player_position())
	var hex_tile = tilemap.world_to_map(MapUtils.get_hex_center(hex_center))
	if 0 > hex_tile.x or hex_tile.x >= map_grid.size() or 0 > hex_tile.y or hex_tile.y >= map_grid[0].size():
		return
	var tile_entity = map_grid[hex_tile.x][hex_tile.y]
	
	if hex_center != cache_hex_center:
		cursor.global_position = hex_center
		cache_hex_center = hex_center
		var interactable = _is_feature(tile_entity)
		player._on_World_tile_entered(interactable)
	
	var last_mouse_tile = _mouse_hex_tile
	var screen_pos = MapUtils.get_warped_mouse_position()
	_mouse_hex_tile = tilemap.get_global_transform().affine_inverse() * (tilemap.get_viewport_transform().affine_inverse() * screen_pos)
	_mouse_hex_tile = tilemap.world_to_map(MapUtils.get_hex_center(_mouse_hex_tile))
	var in_bounds_new = 0 <= _mouse_hex_tile.x and _mouse_hex_tile.x < map_grid.size() and 0 <= _mouse_hex_tile.y and _mouse_hex_tile.y < map_grid[0].size()
	var in_bounds_last = 0 <= last_mouse_tile.x and last_mouse_tile.x < map_grid.size() and 0 <= last_mouse_tile.y and last_mouse_tile.y < map_grid[0].size()
	if last_mouse_tile != _mouse_hex_tile and in_bounds_last and in_bounds_new:
		var last_entity = map_grid[last_mouse_tile.x][last_mouse_tile.y]
		var new_entity = map_grid[_mouse_hex_tile.x][_mouse_hex_tile.y]
		if _is_feature(last_entity):
			last_entity.mouse_exited()
		if _is_feature(new_entity):
			new_entity.mouse_entered()


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
	# generate provisional map with perlin noise
	var used_cells = tilemap.get_used_cells()
	var noise = _noise_generation(_rng.randi(), used_cells)
	
	# balance blocked/empty ratio
	_balance_mountain_ratio(used_cells, noise)
	
	# force open area around player
	var radius = 4 # x tile radius
	var center = Vector2(map_grid.size() / 2 - 1, map_grid[0].size() / 2 - 1)
	_force_open_area(center, radius)
	
	# guaranteing that there are no inaccessible areas on the map
	var buckets = _open_clusters(used_cells)
	_connect_cluster(buckets)
	
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
	for cell in used_cells:
		if map_grid.size() <= cell.x:
			map_grid.append([])
		# cells MUST form a rectangle and cells MUST start at (0,0), otherwise, it would be a pain in the ass
		if map_grid[cell.x].size() <= cell.y:
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
		
		print("new rebalance with threshold: %s" % empty_thresh)
		
		for cell in used_cells:
			if _noise_map_process_cell(cell, simplex_noise.get_noise_2dv(cell), empty_thresh) == TileType.MOUNTAIN:
				mountain_count += 1
		mountain_ratio = float(mountain_count) / float(used_cells.size())
		tries += 1
		print("mountain to empty ratio: %s" % mountain_ratio)


# force an open area around the center of the map
func _force_open_area(center : Vector2, radius : int):
	
	var square_rad = pow(radius, 2)
	var index = Vector2(center.x - radius + 1, center.y - radius + 1)
	while index.x <= center.x + radius - 1:
		index.y = center.y - radius + 1
		while index.y <= center.y + radius - 1:
			if index.distance_squared_to(center) <= square_rad:
				map_grid[index.x][index.y] = TileType.EMPTY
			index.y += 1
		index.x += 1


# identify all empty clusters to make sure no area is unreachable
func _open_clusters(used_cells : Array):
	var buckets = [] # array of arrays, each array is a group of connected cells on the map
	var tagged = {} # dict of the status of all cells; -2: mountain, -1: untagged, 0+: tagged to a bucket (ix of bucket)
	var cells_queue = used_cells.duplicate(true)
	
	# initialise tags
	for cell in used_cells:
		tagged[cell] = -2 if map_grid[cell.x][cell.y] == TileType.MOUNTAIN else -1
	
	var bucket_ix = 0
	while cells_queue.size():
		var cell = cells_queue.back() # head of queue
		
		if tagged[cell] == -1: # untagged and a mountain
			buckets.append([])
			_traverse_neighbours(cell, bucket_ix, buckets, tagged, Vector2(map_grid.size(), map_grid[0].size()))
			bucket_ix += 1 # next bucket only if a new group was traversed
		
		cells_queue.pop_back() # remove this cell
	
	var str_sizes = ""
	for b in buckets:
		str_sizes += str(b.size()) + "-"
	print("Found %s buckets of sizes: %s" % [buckets.size(), str_sizes])
	
	return buckets


# traverse cell neighbours
func _traverse_neighbours(cell : Vector2, bucket_ix : int, buckets : Array, tagged : Dictionary, siz : Vector2):
	tagged[cell] = bucket_ix
	buckets[bucket_ix].append(cell)
	var neighs = [cell + Vector2.RIGHT, cell + Vector2.DOWN, cell + Vector2.LEFT, cell + Vector2.UP]
	for n in neighs:
		if n.x >= 0 and n.x < siz.x and n.y >= 0 and n.y < siz.y and tagged[n] == -1: # untagged and not a mountain
			_traverse_neighbours(n, bucket_ix, buckets, tagged, siz)


# connect all empty clusters to make sure no area is inaccessible
func _connect_cluster(clusters):
	var size_threshold = 6 # each bucket must have at least this number of cells, or the will simply be filled with mountain
	var centers = [] # the center position of each bucket
	var ignored_buckets = 0
	var biggest_cluster = 0 # ix of biggest cluster
	var biggest_size = clusters[0].size() # size of biggest cluster
	
	var bucket_ix = 0
	for bucket in clusters:
		if bucket.size() > biggest_size: # find biggest cluster
			biggest_cluster = bucket_ix
			biggest_size = bucket.size()
		if bucket.size() >= size_threshold: # if cluster is big enough
			var cpos = Vector2.ZERO
			for cell in bucket:
				cpos += cell
			cpos = cpos / bucket.size() # mean average of all positions
			cpos.x = floor(cpos.x)
			cpos.y = floor(cpos.y)
			while bucket_ix >= centers.size():
				centers.append(null)
			centers[bucket_ix] = cpos
		else:
			ignored_buckets += 1
			for cell in bucket:
				map_grid[cell.x][cell.y] = TileType.MOUNTAIN
		bucket_ix += 1
	
	if centers.size() - ignored_buckets > 1: # if there's more than one bucket
		var center_ix = 0
		var pos1 = centers[biggest_cluster]
		var pos2 = centers[0]
		while center_ix < centers.size():
			if center_ix != biggest_cluster:
				pos2 = centers[center_ix]
				
				# linear equation
				var m = (pos2.y - pos1.y) / (pos2.x - pos1.x)
				var b = pos1.y - (m * pos1.x)
				
				var dir = 1 if pos2.x > pos1.x else -1 # direction of line
				
				var xx = pos1.x
				while xx != pos2.x:
					var yy = m * xx + b # solve equation finding corresponding y coord
					map_grid[xx][yy] = TileType.EMPTY # set all tiles in the line as empty
					xx += dir
				
			center_ix += 1
	
	print("%s buckets were discarded for being too small" % [ignored_buckets])


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

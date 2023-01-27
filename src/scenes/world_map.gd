extends Node2D


# to be used solely on the process of procedural generation
enum TileType{
	EMPTY,
	MOUNTAIN,
	FEATURE, # feature type should never be used at the same time as either settlement or facility, it is merely a temporary type
	SETTLEMENT,
	FACILITY,
	EVENT_SCENE,
}

export (PackedScene) var MOUNTAIN_SCENE
export (PackedScene) var OUT_MOUNTAIN_SCENE
export (PackedScene) var SETTLEMENT_SCENE
export (PackedScene) var FACILITY_SCENE
export (PackedScene) var EVENT_SCENE

export var MAP_WID = 50
export var MAP_HEI = 30

const FEATURE_TILES_COUNT = 25 # number of feature tiles to be distributed in the map
const SETTLEMENT_FACILITY_RATIO = 0.4 # settlement to facility ratio
const START_RADIUS = 4 # x tile radius of open area
const DISCOVER_RANGE = 4 # range at which tiles are discovered
const FEATURE_SPACING = 3 # minimum space between features on generation

onready var map_perspective = $MapEffect
onready var sky = $Sky
onready var parallax_sky = $ParallaxSky
onready var entities = $Entities
onready var bg_music_player = $AudioStreamPlayer

onready var tilemap = $TileMap
onready var out_tilemap = $Background
onready var cursor = $Cursor
onready var player = $Entities/Player
onready var mountains = $Entities/Mountains
onready var settlements = $Entities/Settlements
onready var facilities = $Entities/Facilities
onready var events = $Entities/Events

var hex_center = Vector2.ZERO
var cache_hex_center = Vector2.ZERO
var _mouse_hex_tile = Vector2(-1, -1)

var _rng = RandomNumberGenerator.new()
var map_grid = [] # map grid with references to all game entities
var vacant_tiles = {} # dict of all empty tiles, on which feature tiles can be generated
						# each entry is an int value corresponding to the amount of features occupying it (or surrounding)
var discovered = [] # map cells not obscured by fog of war (true or false)
var map_center = Vector2(MAP_WID/2 - 1, MAP_HEI/2 - 1)


func _ready() -> void:
	MapUtils.set_ref_tilemap($TileMap)
	_rng.randomize()
	_resize_map()
	_generate_map()
	MapUtils.set_dimensions(map_grid[0].size(), map_grid.size())
	hex_center = MapUtils.get_hex_center(_get_player_position())
	cache_hex_center = hex_center
	random_bg_music()
	
	if MapUtils.is_enabled():
		sky.visible = true
		parallax_sky.visible = true
		map_perspective.visible = true
	else:
		sky.visible = false
		parallax_sky.visible = false
		map_perspective.visible = false
	
	# Manually instance starting features
	var ev = Global.generate_event(Global.get_event_data("starter", Global.EventTypes.QUEST), map_center + Vector2.DOWN, false)
	# vv why the hell is this necessary???? vv
	_on_spawn_event_request(ev)
	_instance_map_scene(map_center + Vector2(-2, 0), TileType.FACILITY)
	_instance_map_scene(map_center + Vector2(1, -3), TileType.SETTLEMENT)
	
	Global.get_player().global_position = tilemap.map_to_world(map_center) + Vector2(tilemap.cell_size.x / 2, tilemap.cell_size.y * 2/3)
	_discover_around(map_center)
	
	var _v = EventManager.connect("feature_tile_placed", self, "_on_feature_tile_placed")
	_v = EventManager.connect("feature_tile_left", self, "_on_feature_tile_left")
	_v = EventManager.connect("spawn_event_request", self, "_on_spawn_event_request")
	
	# TODO: remove
	var quest_data = Global.get_quest_data("quest2")
	WorldData.quest_log.regiter_new_quest(quest_data, settlements.get_child(settlements.get_child_count()-1))


func _physics_process(_delta: float) -> void:
	hex_center = MapUtils.get_hex_center(_get_player_position())
	var hex_tile = _get_cell_from_position(hex_center)
	if 0 > hex_tile.x or hex_tile.x >= map_grid.size() or 0 > hex_tile.y or hex_tile.y >= map_grid[0].size():
		return
	var tile_entity = map_grid[hex_tile.x][hex_tile.y]
	
	# player switched tiles
	if hex_center != cache_hex_center:
		cursor.global_position = hex_center
		cache_hex_center = hex_center
		var interactable = _is_feature(tile_entity)
		player._on_World_tile_entered(interactable)
		_discover_around(hex_tile)
	
	# find the tile being hovered
	var last_mouse_tile = _mouse_hex_tile
	var screen_pos = MapUtils.get_warped_mouse_position()
	# the transform must be manually tailored, because the viewport's transform takes into account the whole window space
	# while the mouse position only takes the screen space, fuck you Godot
	var transf = tilemap.get_viewport_transform().affine_inverse()
	transf.x = transf.x.normalized()
	transf.y = transf.y.normalized()
	_mouse_hex_tile = tilemap.get_global_transform().affine_inverse() * (transf * screen_pos)
	Global.set_mouse_in_perspective(_mouse_hex_tile if MapUtils.ENABLED else get_global_mouse_position())
	_mouse_hex_tile = _get_cell_from_position(_mouse_hex_tile)
	var in_bounds_new = _is_cell_in_bounds(_mouse_hex_tile)
	var in_bounds_last = _is_cell_in_bounds(last_mouse_tile)
	if last_mouse_tile != _mouse_hex_tile and in_bounds_last and in_bounds_new:
		var last_entity = map_grid[last_mouse_tile.x][last_mouse_tile.y]
		var new_entity = map_grid[_mouse_hex_tile.x][_mouse_hex_tile.y]
		if _is_feature(last_entity):
			last_entity.mouse_exited()
		if _is_feature(new_entity):
			new_entity.mouse_entered()
	
	$HUD/Control/Label.text = str(_get_cell_from_position(_get_player_position()))


func generate_event_tile(event : Event):
	var pos_cell = event.cell_pos
	
	if pos_cell == Vector2(-1, -1):
		var empties = []
		var center = map_center
		var square_rad = pow(START_RADIUS, 2)
		for cell in vacant_tiles: # recalculate all empty tiles every turn
			if vacant_tiles[cell] == 0 and cell.distance_squared_to(center) > square_rad and cell.y < map_grid[0].size()-1:
				empties.append(cell)
		var random_pos_ix = _rng.randi_range(0, empties.size()-1)
		pos_cell = empties[random_pos_ix]
		
	var world_pos = tilemap.map_to_world(pos_cell)
	var pos = world_pos + Vector2(tilemap.cell_size.x / 2, tilemap.cell_size.y * 2/3)
	
	event.cell_pos = pos_cell
	event.global_position = pos
	event.set_discovered(false)
	events.add_child(event)
	var cell = _get_cell_from_position(pos)
	map_grid[cell.x][cell.y] = event
	print(pos_cell)


#  || --- HELPER FUNCTIONS --- ||


func _get_player_position():
	return player.global_position


# get the corresponding cell from a position in map
func _get_cell_from_position(position):
	return tilemap.world_to_map(MapUtils.get_hex_center(position))


# return whether a tile entity is a feature tile
func _is_feature(tile_entity):
	if tile_entity != null:
		if tile_entity is Feature:
			return true
	return false


# return whether cell is in map bounds
func _is_cell_in_bounds(cell):
	return cell.x >= 0 and cell.x < map_grid.size() and cell.y >= 0 and cell.y < map_grid[0].size()


# occupy a position in the map, also marking the ones surrounding it as occupied
func _occupy_around(cell, radius, occupy):
	var neighs = _get_cells_around(cell, radius)
	for n in neighs:
		_occupy_cell(n, occupy)


# increments the tiles the cell will occupy, so that, only when no feature is occupying it, it can be used
func _occupy_cell(cell, occupy):
	if _is_cell_in_bounds(cell):
		if occupy:
			vacant_tiles[cell] += 1
		else:
			vacant_tiles[cell] = max(vacant_tiles[cell]-1, 0)


# returns a list of all cells around a given origin cell
func _get_cells_around(origin, radius):
	var lst = []
	
	var square_rad = pow(radius, 2)
	var index = Vector2(origin.x - radius, origin.y - radius)
	while index.x <= origin.x + radius:
		index.y = origin.y - radius
		while index.y <= origin.y + radius:
			if index.distance_squared_to(origin) <= square_rad:
				lst.append(index)
			index.y += 1
		index.x += 1
	
	return lst


# || --- TILEMAP MANIPULATION --- ||

# resize map as needed
func _resize_map():
	var id = 0
	var tileset = tilemap.tile_set
	var rect = tileset.tile_get_region(id)
	var size_x = rect.size.x / tileset.autotile_get_size(id).x
	var priorities = []
	var sum = 0.0
	
	# get all priorities of all subtiles in tileset
	for x in range(size_x): 
		var pr = float(tileset.autotile_get_subtile_priority(id, Vector2(x, 0)))
		sum += pr
		priorities.append(pr)
	
	# normalise priorities
	for i in range(priorities.size()):
		priorities[i] /= sum
	
	# fill remaining tiles if map is bigger than 20x20 cells
	for x in range(MAP_WID):
		for y in range(MAP_HEI):
			if tilemap.get_cell(x, y) == -1:
				_set_tilemap_cell(x, y, id, priorities)
	
	_set_border_tiles()


# set border tilemap cells
func _set_border_tiles():
	var tl = Vector2(-10, -10)
	var br = Vector2(MAP_WID + 10, MAP_HEI + 10)
	var xx = tl.x
	var yy = tl.y
	
	# set he border tilemap only around normal map
	while xx < br.x:
		yy = tl.y
		while yy < br.y:
			if not (xx >= 0 and xx < MAP_WID and yy >= 0 and yy < MAP_HEI):
				out_tilemap.set_cell(xx, yy, 0)
			yy += 1
		xx += 1


# set a single tilemap cell at a position respecting priorities
func _set_tilemap_cell(xx, yy, id, priorities : Array = [1.0]):
	var prob = _rng.randf()
	var i = priorities.size()-1
	var priori = 0
	while i >= 0:
		priori += priorities[i]
		if prob <= priori: # select which subtile to use based on cumulative priorities
			break
		i-= 1
	
	tilemap.set_cell(xx, yy, id, false, false, false, Vector2(i, 0))


# mark a cell as discovered or hidden as opposed to fog of war
func _set_cell_discovery(cell, _disc = true):
	var tilemap_subtile = tilemap.get_cell_autotile_coord(cell.x, cell.y)
	tilemap_subtile.y = 0 if _disc else 1
	tilemap.set_cellv(cell, 0, false, false, false, tilemap_subtile)
	var entity = map_grid[cell.x][cell.y]
	if _is_feature(entity):
		entity.set_discovered(_disc)
		discovered[cell.x][cell.y] = _disc
	elif entity is Mountain:
		entity.set_discovered(_disc)


# discover all cells around a cell
func _discover_around(cell):
	var to_discover = _get_cells_around(cell, DISCOVER_RANGE)
	for neigh in to_discover:
		if _is_cell_in_bounds(neigh) and not discovered[neigh.x][neigh.y]: # don't rediscover a cell
			_set_cell_discovery(neigh)


# || --- MAP GENERATION --- ||

# initialise vacant tiles, accounting only for mountains
func _init_vacant_tiles(cells):
	for cell in cells:
		if map_grid[cell.x][cell.y] == TileType.MOUNTAIN:
			vacant_tiles[cell] = 1
		else:
			vacant_tiles[cell] = 0


# map generation pipeline
func _generate_map():
	# generate provisional map with perlin noise
	var used_cells = tilemap.get_used_cells()
	var noise = _noise_generation(_rng.randi(), used_cells)
	
	# balance blocked/empty ratio
	_balance_mountain_ratio(used_cells, noise)
	
	# force open area around player
	var center = map_center
	_force_open_area(center)
	
	# guaranteing that there are no inaccessible areas on the map
	var buckets = _open_clusters(used_cells)
	_connect_cluster(buckets)
	
	_init_vacant_tiles(used_cells)
	
	# evenly distribute feature tiles
	_distribute_features()
	
	# re-initialise vacant cells, now with the initial features
	_init_vacant_tiles(used_cells)
	
	# actual process of populating the map with the apropriate scenes
	for cell in used_cells:
		_instance_map_scene(cell, map_grid[cell.x][cell.y])
	
	# initialise all cells as undiscovered
	for _xx in range(map_grid.size()):
		discovered.append([])
		for _yy in range(map_grid[_xx].size()):
			discovered[_xx].append(false)
			_set_cell_discovery(Vector2(_xx, _yy), false)


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
	print("Total tries: " + str(tries))


# force an open area around the center of the map
func _force_open_area(center : Vector2):
	for cell in _get_cells_around(center, START_RADIUS):
		map_grid[cell.x][cell.y] = TileType.EMPTY


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
	str_sizes.erase(str_sizes.length()-1, 1)
	print("Found %s empty area buckets of sizes: %s" % [buckets.size(), str_sizes])
	
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
			var c_ix = _rng.randi_range(0, bucket.size()-1)
			while bucket_ix >= centers.size():
				centers.append(null)
			centers[bucket_ix] = bucket[c_ix]
		else:
			ignored_buckets += 1
			for cell in bucket:
				map_grid[cell.x][cell.y] = TileType.MOUNTAIN
		bucket_ix += 1
	
	print("%s buckets were discarded for being too small" % [ignored_buckets])
	print("Bucket centers: " + str(centers))
	print("Bucket cells:")
#	var ix = 0
#	for b in clusters:
#		if ix != biggest_cluster:
#			print(b)
#		ix += 1
	
	# loop through all other centers and connect them to the biggest cluster
	if centers.size() > 1: # if there's more than one bucket
		var center_ix = 0
		var pos1 = centers[biggest_cluster]
		var pos2 = centers[0]
		while center_ix < centers.size():
			if center_ix != biggest_cluster and centers[center_ix] is Vector2:
				pos2 = centers[center_ix]
				
				# linear equation
				var m = (pos2.y - pos1.y) / (pos2.x - pos1.x) if (pos2.x - pos1.x) != 0 else 0
				var b = pos1.y - (m * pos1.x)
				
				var dir = 1 if pos2.x > pos1.x else -1 # direction of line
				
				var xx = pos1.x
				var yy = pos1.y
				while xx != pos2.x:
					var new_yy = round(m * xx + b) # solve equation finding corresponding y coord
					while abs(yy - new_yy) > 1:
						yy = move_toward(yy, new_yy, 1)
						map_grid[xx][yy] = TileType.EMPTY # set all tiles in the line as empty
						#print("Open cell: " + str(Vector2(xx, yy)))
					map_grid[xx][new_yy] = TileType.EMPTY # set all tiles in the line as empty
					#print("Open cell: " + str(Vector2(xx, new_yy)))
					map_grid[xx + dir][new_yy] = TileType.EMPTY # set all tiles in the line as empty
					#print("Open cell: " + str(Vector2(xx + dir, new_yy)))
					xx += dir
					yy = new_yy
				while abs(yy - pos2.y) > 1:
					yy = move_toward(yy, pos2.y, 1)
					map_grid[xx][yy] = TileType.EMPTY # set all tiles in the line as empty
					#print("Open cell: " + str(Vector2(xx, yy)))
				
			center_ix += 1


# evenly distribute feature tiles accross map
# this function also marks as filled those tiles around the feature so that features do not spawn adjacent to each other
func _distribute_features():
	var radius = START_RADIUS
	var center = map_center
	var square_rad = pow(radius, 2)
	
	var feature_tiles = [] # list of tiles marked as feature tiles
	
	for _i in range(FEATURE_TILES_COUNT):
		var empties = []
		for cell in vacant_tiles: # recalculate all empty tiles every turn
			if vacant_tiles[cell] == 0 and cell.distance_squared_to(center) > square_rad and cell.y < map_grid[0].size()-1:
				empties.append(cell)
		if empties.size() == 0: # failsafe, player simply got bad luck and will have less features than they should
			print("%s feature tiles were not placed due to no vacant slots" % [FEATURE_TILES_COUNT-_i])
			break
		var random_pos_ix = _rng.randi_range(0, empties.size()-1)
		var cell = empties[random_pos_ix]
		_occupy_around(cell, FEATURE_SPACING, true)
		map_grid[cell.x][cell.y] = TileType.FEATURE
		feature_tiles.append(cell)
	
	for _i in range(FEATURE_TILES_COUNT*SETTLEMENT_FACILITY_RATIO): # select which features will be settlements
		var _rand_tile = feature_tiles[_rng.randi_range(0, feature_tiles.size()-1)]
		map_grid[_rand_tile.x][_rand_tile.y] = TileType.SETTLEMENT
		feature_tiles.erase(_rand_tile)
	for cell in feature_tiles: # all remaining features will be facilities
		map_grid[cell.x][cell.y] = TileType.FACILITY


# populate with the actual scene instances
func _instance_map_scene(cell : Vector2, scene_type : int):
	var world_pos = tilemap.map_to_world(cell)
	var real_position = world_pos + Vector2(tilemap.cell_size.x / 2, tilemap.cell_size.y * 2/3)
	match scene_type:
		TileType.MOUNTAIN:
			if MOUNTAIN_SCENE != null:
				var mountain = MOUNTAIN_SCENE.instance()
				mountain.global_position = real_position
				mountain.set_discovered(false)
				mountains.add_child(mountain)
				map_grid[cell.x][cell.y] = mountain
		TileType.SETTLEMENT:
			if SETTLEMENT_SCENE != null:
				var settlement = SETTLEMENT_SCENE.instance()
				settlement.global_position = real_position
				settlement.set_discovered(false)
				settlements.add_child(settlement)
				map_grid[cell.x][cell.y] = settlement
		TileType.FACILITY:
			if SETTLEMENT_SCENE != null:
				var facility = FACILITY_SCENE.instance()
				facility.global_position = real_position
				facility.set_discovered(false)
				facilities.add_child(facility)
				map_grid[cell.x][cell.y] = facility


# || --- SIGNALS --- ||


# callback function when player presses interact button
func _on_Player_interact(position):
	var hex_tile = _get_cell_from_position(position)
	
	var tile_entity = map_grid[hex_tile.x][hex_tile.y]
	if tile_entity is Object and tile_entity.has_method("interact"):
		WorldData.quest_log.on_feature_interacted(tile_entity)
		tile_entity.interact()

# when a feature tile enters the map
func _on_feature_tile_placed(feature : Feature):
	var cell = _get_cell_from_position(feature.global_position)
	var neighs = _get_cells_around(cell, 1)
	var occupied = neighs.duplicate()
	occupied.append(cell)
	
	feature.occupied_cells = []
	feature.occupied_cells.append_array(occupied)
	for o in occupied:
		_occupy_cell(o, true)
	map_grid[cell.x][cell.y] = feature


# when a feature tile leaves the map
func _on_feature_tile_left(feature : Feature):
	for o in feature.occupied_cells:
		_occupy_cell(o, false)
	var cell = _get_cell_from_position(feature.global_position)
	map_grid[cell.x][cell.y] = TileType.EMPTY


# process a request to generate a new event tile
func _on_spawn_event_request(event):
	generate_event_tile(event)

func random_bg_music():
	var music_file
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var num = rng.randi_range(0,3)
	print(num)
	match num:
		0:
			music_file = "res://assets/sfx/ui/UI_TabChanged.wav"
		1:
			music_file = "res://assets/sfx/world/floating.wav"
		2:
			music_file = "res://assets/sfx/world/dramatic_scroller.wav"
		3: 
			music_file = "res://assets/sfx/world/ocean_drift.wav"
	if music_file != "":
		bg_music_player.stream = load(music_file)
		bg_music_player.play()
		bg_music_player.connect("finished", self, "random_bg_music")

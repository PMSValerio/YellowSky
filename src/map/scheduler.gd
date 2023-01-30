extends Node

onready var world_bg_music = get_node("/root/World/BG_MusicPlayer")

var _disaster_scenes = {
	#Global.Disasters.TEST: preload("res://src/disasters/TestDisaster.tscn"),
	Global.Disasters.TORNADO: preload("res://src/disasters/tornado/Tornado.tscn"),
	Global.Disasters.STORM: preload("res://src/disasters/thunderstorm/Storm.tscn"),
	Global.Disasters.RAIN: preload("res://src/disasters/rainfall/Rainfall.tscn"),
	#Global.Disasters.AMOGEDDON: preload("res://src/disasters/amogeddon/Amogeddon.tscn")
}

const TIME_UPDATE_FREQ = 50

# setting reference to canvas layer for disaster
export (NodePath) var disaster_layer_path
# setting reference to background canvas layer
export (NodePath) var background_layer_path

onready var disaster_layer = get_node(disaster_layer_path)
onready var background_layer = get_node(background_layer_path)
onready var nighttime = disaster_layer.get_node("NightLayer")
onready var tween = (nighttime.get_node("Tween") as Tween)

var total_elapsed_time = 0
var days = 0
var _elapsed = 0
var _next_interval = -1
var _next_disaster = Global.Disasters.STORM

var day_timer = 0 # timer for each day

var disaster_node = null

var disaster_running = false

var distributions = {
	Global.DAY_DURATION: { # if time is before a total day, no disasters can occur
	},
	Global.DAY_DURATION * 2: { # from the second day, storms are frequent and acid rain is rare
		Global.Disasters.STORM: 0.8,
		Global.Disasters.RAIN: 0.2,
	},
	Global.DAY_DURATION * 3: { # third day on, tornadoes start rarely
		Global.Disasters.RAIN: 0.6,
		Global.Disasters.STORM: 0.3,
		Global.Disasters.TORNADO: 0.1,
	},
	Global.DAY_DURATION * 4: { # from the fourth day, tornadoes are a lot more frequent
		Global.Disasters.TORNADO: 0.5,
		Global.Disasters.RAIN: 0.4,
		Global.Disasters.STORM: 0.1,
	},
	Global.DAY_DURATION * 5: { # fifth day onwards, almost just tornadoes
		Global.Disasters.TORNADO: 0.7,
		Global.Disasters.RAIN: 0.3,
	}
}
var intervals = {
	Global.DAY_DURATION: Global.DAY_DURATION,
	Global.DAY_DURATION * 2: Global.DAY_DURATION * 0.1,
	Global.DAY_DURATION * 3: Global.DAY_DURATION * 0.08,
	Global.DAY_DURATION * 4: Global.DAY_DURATION * 0.06,
	Global.DAY_DURATION * 5: Global.DAY_DURATION * 0.04,
}


func _ready():
	_schedule_new_disaster()
	var _v = EventManager.connect("attempt_sleep", self, "_skip_day")


func _process(delta: float) -> void:
	if not disaster_running and _next_interval > 0:
		total_elapsed_time += delta
		
		_elapsed += delta
		if _elapsed >= _next_interval:
			_elapsed = 0
			_process_disaster(_next_disaster)
	
	_update_day(delta)


#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("debug"):
		#_next_interval = 1
		#_skip_day()


func _process_disaster(disaster_id):
	if disaster_layer != null and disaster_id in _disaster_scenes:
		disaster_node = _disaster_scenes[disaster_id].instance()
		disaster_node.background_layer = background_layer
		disaster_node.connect("disaster_end", self, "_on_disaster_end")
		disaster_layer.add_child(disaster_node)
		disaster_node.start()
		disaster_running = true
	else:
		_schedule_new_disaster() # try again


func _schedule_new_disaster():
	# TODO: calculate based on total progression
	_next_interval = 20 + (randf() * 5)
#	_next_disaster = Global.Disasters.AMOGEDDON if randf() < 0.2 else Global.Disasters.TORNADO
	var dist = {}
	for phase in distributions:
		_next_interval = intervals[phase]
		dist = distributions[phase]
		if total_elapsed_time < phase:
			break
	_next_disaster = _new_disaster_prob(dist)


func _new_disaster_prob(dist):
	if dist.size() <= 0:
		return -1
	var _ids = dist.keys()
	var _probs = dist.values()
	var chance = randf()
	var i = 0
	while i < _probs.size(): # turn into cumulative probability
		if i > 0:
			_probs[i] = _probs[i-1] + _probs[i]
		if chance <= _probs[i]:
			break
		i += 1
	return _ids[i] if i < _ids.size() else _ids[i-1]


func _on_disaster_end():
	disaster_running = false
	disaster_node.queue_free()
	disaster_node = null
	Global.play_paused_audio(world_bg_music, 1.5)
	_schedule_new_disaster()
	


func _update_day(delta):
	var _last = day_timer
	day_timer += delta
	
	if int(day_timer) % TIME_UPDATE_FREQ:
		EventManager.emit_signal("time_update", day_timer)
	
	if _last < Global.NIGHT_THRESHOLD and day_timer >= Global.NIGHT_THRESHOLD: # start nightfall
		EventManager.emit_signal("start_nightfall")
		tween.interpolate_property(nighttime, "color:a", 0, 0.8, Global.NIGHT_DURATION)
		tween.start()
	elif _last < Global.DAY_DURATION and day_timer >= Global.DAY_DURATION: # quickly go to full black in 2 seconds
		EventManager.emit_signal("start_deep_nightfall")
		tween.interpolate_property(nighttime, "color:a", 0.8, 1.0, 2)
		tween.start()
	elif day_timer >= Global.DAY_DURATION + 3: # reset to day
		day_timer = 0.0
		days += 1
		WorldData.day_passed()
		EventManager.emit_signal("night_penalty")
		tween.interpolate_property(nighttime, "color:a", 1, 0, 2)
		tween.start()


func _skip_day():
	day_timer = 0.0
	days += 1
	tween.remove_all()
	tween.interpolate_property(nighttime, "color:a", nighttime.color.a, 0, 2)
	tween.start()

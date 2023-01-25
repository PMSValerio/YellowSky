extends Node

# shouldnt this be made in the Global script itself?
# Nope, Global is accessible to everyone and not everyone needs the actual disaster scenes
var _disaster_scenes = {
	Global.Disasters.TEST: preload("res://src/disasters/TestDisaster.tscn"),
	Global.Disasters.TORNADO: preload("res://src/disasters/tornado/Tornado.tscn"),
	Global.Disasters.STORM: preload("res://src/disasters/thunderstorm/Storm.tscn"),
	Global.Disasters.AMOGEDDON: preload("res://src/disasters/amogeddon/Amogeddon.tscn")
}

# setting reference to canvas layer for disaster
export (NodePath) var disaster_layer_path
# setting reference to background canvas layer
export (NodePath) var background_layer_path

onready var disaster_layer = get_node(disaster_layer_path)
onready var background_layer = get_node(background_layer_path)
onready var nighttime = disaster_layer.get_node("NightLayer")
onready var tween = (nighttime.get_node("Tween") as Tween)
onready var _day_threshold = Global.DAY_DURATION - Global.NIGHT_THRESHOLD

var total_elapsed_time = 0
var days = 0
var _elapsed = 0
var _next_interval = -1
var _next_disaster = Global.Disasters.STORM

var day_timer = 0 # timer for each day

var disaster_node = null

var disaster_running = false

func _process(delta: float) -> void:
	if not disaster_running and _next_interval > 0:
		total_elapsed_time += delta
		
		_elapsed += delta
		if _elapsed >= _next_interval:
			_elapsed = 0
			_process_disaster(_next_disaster)
	
	_update_day(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		_next_interval = 1


func _process_disaster(disaster_id):
	if disaster_layer != null and disaster_id in _disaster_scenes:
		disaster_node = _disaster_scenes[disaster_id].instance()
		disaster_node.background_layer = background_layer
		disaster_node.connect("disaster_end", self, "_on_disaster_end")
		disaster_layer.add_child(disaster_node)
		disaster_node.start()
		disaster_running = true
	print("Disaster %s started" % disaster_id)


func _schedule_new_disaster():
	# TODO: calculate based on total progression
	_next_interval = 20 + (randf() * 5)
	_next_disaster = Global.Disasters.AMOGEDDON if randf() < 0.2 else Global.Disasters.TORNADO


func _on_disaster_end():
	print("Disaster ended")
	disaster_running = false
	disaster_node.queue_free()
	disaster_node = null
	_schedule_new_disaster()


func _update_day(delta):
	var _last = day_timer
	day_timer += delta
	if _last < _day_threshold and day_timer >= _day_threshold:
		tween.interpolate_property(nighttime, "color:a", 0, 0.8, Global.NIGHT_THRESHOLD)
		tween.start()
	elif _last < Global.DAY_DURATION and day_timer >= Global.DAY_DURATION: # quickly go to full black in 2 seconds
		tween.interpolate_property(nighttime, "color:a", 0.8, 1.0, 2)
		tween.start()
	elif day_timer >= Global.DAY_DURATION + 3:
		day_timer = 0.0
		days += 1
		EventManager.emit_signal("night_penalty")
		tween.interpolate_property(nighttime, "color:a", 1, 0, 2)
		tween.start()


func _skip_day():
	day_timer = 0.0
	days += 1
	tween.stop_all()
	tween.interpolate_property(nighttime, "color:a", nighttime.color.a, 0, 2)
	tween.start()

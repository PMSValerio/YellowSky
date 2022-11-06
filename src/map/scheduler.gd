extends Node


var _disaster_scenes = {
	Global.Disasters.TEST: preload("res://src/disasters/TestDisaster.tscn"),
}

export (NodePath) var disaster_layer_path

onready var disaster_layer = get_node(disaster_layer_path)

var total_elapsed_time = 0

var _elapsed = 0
var _next_interval
var _next_disaster = null

var disaster_node = null


func _ready() -> void:
	# TODO: remove
	_next_interval = 5
	_next_disaster = Global.Disasters.TEST


func _process(delta: float) -> void:
	total_elapsed_time += delta
	
	_elapsed += delta
	if _elapsed >= _next_interval:
		_elapsed = 0
		_process_disaster(_next_disaster)
		_schedule_new_disaster()


func _process_disaster(disaster_id):
	if disaster_layer != null and disaster_id in _disaster_scenes:
		if disaster_node != null:
			disaster_node.queue_free()
		disaster_node = _disaster_scenes[disaster_id].instance()
		disaster_layer.add_child(disaster_node)
	print("Disaster %s started" % disaster_id)


func _schedule_new_disaster():
	# TODO: calculate based on total progression
	_next_interval = 10
	_next_disaster = Global.Disasters.TEST

extends Node2D
class_name Feature


func interact() -> void:
	print("I am a %s, at position %s, tile %s" % [name, global_position, MapUtils.get_ref_tilemap().world_to_map(global_position)])

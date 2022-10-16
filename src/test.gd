extends Node

signal tile_entered(id)

var do_once = true
var cache_hex_center = Vector2.ZERO
var hex_center = Vector2.ZERO

func _ready() -> void:
	Global.set_cam($Entities/Node2D/MyCamera)
	MapUtils.set_ref_tilemap($HexTileMap)

	hex_center = MapUtils.get_hex_center($Entities/Node2D.global_position)
	cache_hex_center = MapUtils.get_hex_center($Entities/Node2D.global_position)


	if MapUtils.is_enabled():
		$Sky.visible = true
		$MapEffect.visible = true
	else:
		$Sky.visible = false
		$MapEffect.visible = false


func _physics_process(_delta: float) -> void:
	hex_center = MapUtils.get_hex_center($Entities/Node2D.global_position)

	if hex_center != cache_hex_center:
		$Cursor.global_position = hex_center
		cache_hex_center = hex_center

		emit_signal("tile_entered", MapUtils.get_hex_id(hex_center))

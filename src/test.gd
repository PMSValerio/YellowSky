extends Node


func _ready() -> void:
	Global.set_cam($Entities/Node2D/Camera2D)
	MapUtils.set_ref_tilemap($TileMap)
	if MapUtils.is_enabled():
		$Sky.visible = true
		$MapEffect.visible = true
	else:
		$Sky.visible = false
		$MapEffect.visible = false


func _physics_process(_delta: float) -> void:
	var hex_center = MapUtils.get_hex_center($Entities/Node2D.global_position)
	$Cursor.global_position = hex_center

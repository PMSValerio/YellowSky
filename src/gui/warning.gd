extends Node2D


var rect = Rect2(0, 0, 40, 40)
var mouse_in = false


func _ready() -> void:
	$MenuTooltip.set_text("[Click to Dismiss]")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if mouse_in:
				visible = false


func _physics_process(_delta: float) -> void:
	var tilemap = MapUtils.get_ref_tilemap()
	rect.position = tilemap.get_viewport_transform() * (tilemap.get_global_transform() * global_position) - rect.size/2
#	var mouse = Global.get_mouse_in_perspective()
	var mouse = get_viewport().get_mouse_position()
	mouse_in = rect.has_point(mouse)
	$MenuTooltip.visible = mouse_in


func _on_MenuTooltipProxy_mouse_entered() -> void:
	mouse_in = true


func _on_MenuTooltipProxy_mouse_exited() -> void:
	mouse_in = false

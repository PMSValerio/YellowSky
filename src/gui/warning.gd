extends Node2D


onready var border_left = 32
onready var border_right = MapUtils.screen_wid - 32
onready var border_up = (1-MapUtils.HORIZON_Y) * MapUtils.screen_hei - 32
onready var border_down = MapUtils.screen_hei - 96 - 32

var rect = Rect2(0, 0, 40, 40)
var mouse_in = false


func _ready() -> void:
	set_tooltip_text("[Click to Dismiss]")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if mouse_in:
				visible = false


func _physics_process(_delta: float) -> void:
	var tilemap = MapUtils.get_ref_tilemap()
	var pos = tilemap.get_viewport_transform() * (tilemap.get_global_transform() * global_position)
	pos.x = clamp(pos.x, border_left, border_right)
	pos.y = clamp(pos.y, border_up, border_down)
	$Anchor.global_position = tilemap.get_global_transform().affine_inverse() * (tilemap.get_viewport_transform().affine_inverse() * pos)
	
	rect.position = pos - rect.size/2
	var mouse = get_viewport().get_mouse_position()
	mouse_in = rect.has_point(mouse)
	$Anchor/MenuTooltip.visible = mouse_in


func set_tooltip_text(text : String):
	$Anchor/MenuTooltip.set_text(text)

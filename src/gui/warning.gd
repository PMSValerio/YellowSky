extends Node2D


onready var border_left = 32
onready var border_right = MapUtils.screen_wid - 32
onready var border_up = (1-MapUtils.HORIZON_Y) * MapUtils.screen_hei - 32
onready var border_down = MapUtils.screen_hei - 96 - 32

var rect = Rect2(0, 0, 40, 40)
var mouse_in = false
var _type
var _text : String

var _type_data = {
	Global.Warnings.MSQ: ["info", ""],
	Global.Warnings.F_DAMAGE: ["damage", "Facility damaged!"],
	Global.Warnings.S_DAMAGE: ["damage", "Settlement damaged!"],
	Global.Warnings.F_CRITICAL: ["critical", "Facility destroyed!"],
	Global.Warnings.S_CRITICAL: ["critical", "Settlement destroyed!"],
	Global.Warnings.QUEST: ["quest", ""],
	Global.Warnings.NO_FUEL: ["fuel", "Facility out of fuel!"],
	Global.Warnings.FULL: ["full", "Facility full!"],
}


func _ready() -> void:
	set_type(Global.Warnings.MSQ)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if mouse_in:
				toggle(false)


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
	$Anchor/MenuTooltip.set_text(text + " [Click to dismiss]")
	_text = text + " [Click to dismiss]"


func set_type(type, custom_text = ""):
	if type in _type_data:
		$Anchor/AnimatedSprite.play(_type_data[type][0])
		set_tooltip_text(custom_text if custom_text != "" else _type_data[type][1])
		_type = type


func get_type():
	return _type


func get_text() -> String:
	return _text


func toggle(onoff : bool):
	visible = onoff

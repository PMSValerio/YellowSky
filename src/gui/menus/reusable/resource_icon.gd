extends TextureRect


onready var tooltip = $MenuTooltipProxy
var text = ""


func _ready() -> void:
	tooltip.hint_tooltip = text


func init(rec_id, size) -> void:
	texture = Global.resource_icons[rec_id]
	rect_min_size = Vector2(size, size)
	text = Global.resource_names[rec_id]
	if tooltip != null:
		tooltip.hint_tooltip = Global.resource_names[rec_id]


func init_manual(icon : Texture, _text : String, size) -> void:
	texture = icon
	rect_min_size = Vector2(size, size)
	text = _text
	if tooltip != null:
		tooltip.hint_tooltip = _text


func clear() -> void:
	init_manual(null, "", 32)

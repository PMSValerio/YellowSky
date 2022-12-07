extends TextureRect


onready var tooltip = $MenuTooltipProxy


func init(rec_id, size) -> void:
	texture = Global.resource_icons[rec_id]
	rect_min_size = Vector2(size, size)
	tooltip.hint_tooltip = Global.resource_names[rec_id]


func init_manual(icon : Texture, text : String, size) -> void:
	texture = icon
	rect_min_size = Vector2(size, size)
	tooltip.hint_tooltip = text

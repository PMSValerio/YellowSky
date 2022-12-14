extends Control
class_name MenuTooltipProxy

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_PASS


func _make_custom_tooltip(for_text: String) -> Control:
	var tooltip = Global.get_tooltip()
	if tooltip != null:
		tooltip.set_text(for_text)
	return tooltip

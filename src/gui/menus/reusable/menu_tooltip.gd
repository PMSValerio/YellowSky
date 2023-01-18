extends Control


func _ready() -> void:
	VisualServer.canvas_item_set_z_index(get_canvas_item(), 10)


func set_text(text) -> void:
	$PanelContainer/Tooltip.text = text

extends PanelContainer
class_name ResourceButton

signal action_pressed

onready var _texture_rect = $Button/VBoxContainer/TextureRect
onready var _label = $Button/VBoxContainer/Label


func set_texture(texture : Texture) -> void:
	_texture_rect.texture = texture


func set_value(value : int) -> void:
	_label.text = value


func _on_Button_pressed() -> void:
	emit_signal("action_pressed")

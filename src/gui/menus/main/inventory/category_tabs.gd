extends Control


signal switch_tab(category)


func _ready() -> void:
	var _v = $VBoxContainer/Resources.connect("pressed", self, "_on_tab_pressed", [$VBoxContainer/Resources, 0])
	_v = $VBoxContainer/Food.connect("pressed", self, "_on_tab_pressed", [$VBoxContainer/Food, 1])
	_v = $VBoxContainer/Luxury.connect("pressed", self, "_on_tab_pressed", [$VBoxContainer/Luxury, 2])
	_v = $VBoxContainer/Quest.connect("pressed", self, "_on_tab_pressed", [$VBoxContainer/Quest, 3])


func select_category(category):
	if category < $VBoxContainer.get_child_count():
		_on_tab_pressed($VBoxContainer.get_child(category), category)


func _on_tab_pressed(button, category):
	for child in $VBoxContainer.get_children():
		(child as TextureButton).pressed = false
	button.pressed = true
	
	emit_signal("switch_tab", category)

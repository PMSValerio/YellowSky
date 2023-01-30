extends "res://src/gui/menus/reusable/base_outer_menu.gd"

onready var bg_music = $bg_music

func _ready() -> void:
	var _v = EventManager.connect("change_compact_resource", self, "_on_pressed_different_resource")
	bg_music.play()

func _on_pressed_different_resource(rec_id):
	if tabs.current_tab != 0:
		tabs.current_tab = 0
	
	$MarginContainer/PanelContainer/TabContainer/Inventory.toggle_compact_menu_on(rec_id)

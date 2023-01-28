extends Node


onready var days = $Control/MarginContainer/PanelContainer/VBoxContainer/MarginContainer/GridContainer/Days
onready var facilities = $Control/MarginContainer/PanelContainer/VBoxContainer/MarginContainer/GridContainer/Facilities
onready var settlements = $Control/MarginContainer/PanelContainer/VBoxContainer/MarginContainer/GridContainer/Settlements
onready var green_tiles = $Control/MarginContainer/PanelContainer/VBoxContainer/MarginContainer/GridContainer/Green
onready var hope = $Control/MarginContainer/PanelContainer/VBoxContainer/MarginContainer/GridContainer/Hope


func _ready() -> void:
	days.text = str(WorldData.days_passed)
	facilities.text = str(WorldData.facilities_upgraded)
	settlements.text = str(WorldData.settlements_lost)
	green_tiles.text = str(WorldData.green_tiles)
	hope.text = str(WorldData.world_hope)


func _on_Button_pressed() -> void:
	pass # Replace with function body.

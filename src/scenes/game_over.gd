extends Node


onready var days = $Control/ResultsScreen/PanelContainer/VBoxContainer/MarginContainer/GridContainer/Days
onready var facilities = $Control/ResultsScreen/PanelContainer/VBoxContainer/MarginContainer/GridContainer/Facilities
onready var settlements = $Control/ResultsScreen/PanelContainer/VBoxContainer/MarginContainer/GridContainer/Settlements
onready var green_tiles = $Control/ResultsScreen/PanelContainer/VBoxContainer/MarginContainer/GridContainer/Green
onready var hope = $Control/ResultsScreen/PanelContainer/VBoxContainer/MarginContainer/GridContainer/Hope


func _ready() -> void:
	days.text = str(WorldData.days_passed)
	facilities.text = str(WorldData.facilities_upgraded)
	settlements.text = str(WorldData.settlements_lost)
	green_tiles.text = str(WorldData.green_tiles)
	hope.text = str(WorldData.world_hope)
	
	$AnimationPlayer.play("default")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			$Control/ResultsScreen.visible = true
			$Control/GameOver.visible = false


func _on_Button_pressed() -> void:
	var _v = get_tree().change_scene("res://src/scenes/TitleScreen.tscn")

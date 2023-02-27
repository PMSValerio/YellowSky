extends Control


signal pressed

onready var title = $MarginContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/PanelContainer/Title
onready var description = $MarginContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/Description
onready var reward_grid = $MarginContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/ItemRewardGrid
onready var btn = $MarginContainer/PanelContainer/MarginContainer/Button

var quest : Quest


# set up the menu as an accept prompt
func set_accept_prompt(quest_data : Quest):
	title.text = quest_data.name
	description.text = quest_data.description
	reward_grid.populate_items(quest_data.rewards)
	btn.text = "Accept Quest"

# set up the menu as a success screen
func set_success_screen(quest_data : Quest):
	title.text = quest_data.name
	description.text = quest_data.get_dialogue(Quest.Dialog.FINISH)
	reward_grid.populate_items(quest_data.rewards)
	btn.text = "Ok"

func _on_Button_pressed():
	emit_signal("pressed")

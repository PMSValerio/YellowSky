extends Control


var list_item_scene = preload("res://src/gui/menus/main/quests/QuestListItem.tscn")

onready var quest_list = $MarginContainer/HBoxContainer/ScrollContainer/QuestList
onready var quest_details = $MarginContainer/HBoxContainer/ScrollContainer2/QuestDetails


func _ready() -> void:
	update_quests_list()


func update_quests_list():
	for child in quest_list.get_children():
		child.queue_free()
	for quest in WorldData.quest_log.get_quests():
		var list_item = list_item_scene.instance()
		list_item.set_data(quest)
		list_item.connect("pressed", self, "_on_quest_selected", [quest])
		quest_list.add_child(list_item)
	quest_details.visible = false


func _on_quest_selected(quest : Quest):
	quest_details.visible = true
	quest_details.set_up(quest)


func _on_QuestDetails_abandon(quest_id) -> void:
	WorldData.quest_log.abandon_quest(quest_id)
	update_quests_list()

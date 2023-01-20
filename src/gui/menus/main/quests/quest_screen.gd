extends Control


var list_item_scene = preload("res://src/gui/menus/main/quests/QuestListItem.tscn")

onready var quest_list = $MarginContainer/ScrollContainer/QuestList


func _ready() -> void:
	update_quests_list()


func update_quests_list():
	for child in quest_list.get_children():
		child.queue_free()
	for quest in WorldData.quest_log.get_quests():
		var list_item = list_item_scene.instance()
		list_item.set_data(quest)
		quest_list.add_child(list_item)

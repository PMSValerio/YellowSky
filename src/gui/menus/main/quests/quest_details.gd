extends MarginContainer


signal abandon(quest_id)

onready var title = $PanelContainer/VBoxContainer/TitleMarker/Title
onready var description = $PanelContainer/VBoxContainer/Description

onready var event_item_label = $PanelContainer/VBoxContainer/ObjectivesContainer/VBoxContainer/EventItemsLabel
onready var event_item_list = $PanelContainer/VBoxContainer/ObjectivesContainer/VBoxContainer/EventItemsList
onready var event_investigate_container = $PanelContainer/VBoxContainer/ObjectivesContainer/VBoxContainer/HBoxContainer
onready var event_investigate = $PanelContainer/VBoxContainer/ObjectivesContainer/VBoxContainer/HBoxContainer/EventInvestigate
onready var return_item_label = $PanelContainer/VBoxContainer/ObjectivesContainer/VBoxContainer/ReturnItemsLabel
onready var return_item_list = $PanelContainer/VBoxContainer/ObjectivesContainer/VBoxContainer/ReturnItemsList
onready var return_investigate_container = $PanelContainer/VBoxContainer/ObjectivesContainer/VBoxContainer/HBoxContainer2
onready var return_investigate = $PanelContainer/VBoxContainer/ObjectivesContainer/VBoxContainer/HBoxContainer2/ReturnInvestigate

onready var reward_grid = $PanelContainer/VBoxContainer/ItemRewardGrid

var quest : Quest


func _set_up_required_items(item_label, node_list, item_dict):
	var all_match = true # whether player has all items on the list
	for child in node_list.get_children():
		child.queue_free()
	for it in item_dict:
		var label = Label.new()
		var item : Item = InventoryManager.item_stats[it]
		var current_amount = InventoryManager.inventory.get_item_amount(item.type, it)
		var required_amount = item_dict[it]
		if current_amount < required_amount: # if the item amounts match mark them as complete
			all_match = false
			item_label.remove_color_override("font_color")
			label.remove_color_override("font_color")
		else:
			item_label.add_color_override("font_color", Color(0.2,0.2,0.2))
			label.add_color_override("font_color", Color(0.2,0.2,0.2))
		label.text = "        " + item.name + " (" + str(current_amount) + "/" + str(required_amount) + ")"
		node_list.add_child(label)
	
	return all_match


func set_up(_quest : Quest):
	quest = _quest
	
	title.text = quest.name
	description.text = quest.description
	
	if quest.event != null:
		event_investigate_container.visible = true
		if quest.deliver_items == null or quest.deliver_items.size() == 0:
			event_item_label.visible = false
			event_item_list.visible = false
			event_investigate.text = "Investigate location"
		else:
			event_item_label.visible = true
			event_item_list.visible = true
			_set_up_required_items(event_item_label, event_item_list, quest.deliver_items)
			event_investigate.text = "Deliver items to location"
	else:
		event_investigate_container.visible = false
		event_item_label.visible = false
	
	if quest.get_status() == Quest.Status.RETURN:
		event_investigate.add_color_override("font_color", Color(0.2,0.2,0.2))
		
		return_item_label.visible = true
		return_item_list.visible = true
		return_investigate.visible = true
		return_investigate_container.visible = true
		if quest.return_items == null or quest.return_items.size() == 0:
			return_item_label.visible = false
			return_item_list.visible = false
			return_investigate.text = "Return to " + quest.quest_giver.settlement_type.name
		else:
			return_item_label.visible = true
			return_item_list.visible = true
			_set_up_required_items(return_item_label, return_item_list, quest.return_items)
			return_investigate.text = "Bring items back to " + quest.quest_giver.settlement_type.name
	else:
		event_investigate.remove_color_override("font_color")
		
		return_item_label.visible = false
		return_item_list.visible = false
		return_investigate.visible = false
		return_investigate_container.visible = false
	
	reward_grid.populate_items(quest.rewards)


func _on_EventMap_pressed() -> void:
	if is_instance_valid(quest.event):
		quest.event.toggle_warning()
		Global.get_player().set_cam_pos(quest.event.global_position)
		EventManager.emit_signal("pop_menu")


func _on_ReturnMap_pressed() -> void:
	quest.quest_giver.warning.set_type(Global.Warnings.QUEST, quest.name)
	quest.quest_giver.warning.toggle(true)
	Global.get_player().set_cam_pos(quest.quest_giver.global_position)
	EventManager.emit_signal("pop_menu")


func _on_Abandon_pressed() -> void:
	emit_signal("abandon", quest.quest_id)

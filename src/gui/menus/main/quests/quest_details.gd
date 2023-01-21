extends MarginContainer


onready var title = $PanelContainer/VBoxContainer/TitleMarker/Title
onready var description = $PanelContainer/VBoxContainer/Description

onready var event_item_label = $PanelContainer/VBoxContainer/ObjectivesContainer/VBoxContainer/EventItemsLabel
onready var event_item_list = $PanelContainer/VBoxContainer/ObjectivesContainer/VBoxContainer/EventItemsList
onready var event_investigate = $PanelContainer/VBoxContainer/ObjectivesContainer/VBoxContainer/EventInvestigate
onready var return_item_label = $PanelContainer/VBoxContainer/ObjectivesContainer/VBoxContainer/ReturnItemsLabel
onready var return_item_list = $PanelContainer/VBoxContainer/ObjectivesContainer/VBoxContainer/ReturnItemsList
onready var return_investigate = $PanelContainer/VBoxContainer/ObjectivesContainer/VBoxContainer/ReturnInvestigate

onready var reward_grid = $PanelContainer/VBoxContainer/ItemRewardGrid


func _set_up_required_items(node_list, item_dict):
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
		else:
			label.add_color_override("font_color", Color(0.2,0.2,0.2))
		label.text = "        " + item.name + " (" + str(current_amount) + "/" + str(required_amount) + ")"
		node_list.add_child(label)
	
	return all_match


func set_up(quest : Quest):
	title.text = quest.name
	description.text = quest.description
	
	if quest.deliver_items == null or quest.deliver_items.size() == 0:
		event_item_label.visible = false
		event_item_list.visible = false
		event_investigate.text = "Investigate location"
	else:
		event_item_label.visible = true
		event_item_list.visible = true
		_set_up_required_items(event_item_list, quest.deliver_items)
		event_investigate.text = "Deliver items to location"
	
	if quest.return_items == null or quest.return_items.size() == 0:
		return_item_label.visible = false
		return_item_list.visible = false
		return_investigate.text = "Return to " + "<Settlement_Name>"
	else:
		return_item_label.visible = true
		return_item_list.visible = true
		_set_up_required_items(return_item_list, quest.return_items)
		return_investigate.text = "Bring items back to " + "<Settlement_Name>"
	
	reward_grid.populate_items(quest.rewards)

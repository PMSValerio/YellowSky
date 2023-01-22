extends Control


onready var item_list = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/ItemsList

var event_entity : Event = null
var _readied


func _ready() -> void:
	_readied = true
	set_context(event_entity)


func set_context(context):
	if context is Event:
		event_entity = context

	if _readied and event_entity != null and event_entity.associated_quest != null:
		var item_dict : Dictionary
		if event_entity.associated_quest.get_status() == Quest.Status.EVENT:
			item_dict = event_entity.associated_quest.deliver_items
		else:
			item_dict = event_entity.associated_quest.return_items
		
		for child in item_list.get_children():
			child.queue_free()
		for it in item_dict:
			var label = Label.new()
			var item : Item = InventoryManager.item_stats[it]
			var current_amount = InventoryManager.inventory.get_item_amount(item.type, it)
			var required_amount = item_dict[it]
			if current_amount >= required_amount: # if the item amounts match mark them as complete
				label.add_color_override("font_color", Color(0.2,0.2,0.2))
			label.text = "        " + item.name + " (" + str(current_amount) + "/" + str(required_amount) + ")"
			item_list.add_child(label)


func _on_Button_pressed() -> void:
	EventManager.emit_signal("pop_menu")

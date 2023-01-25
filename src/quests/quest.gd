extends Resource
class_name Quest

enum Status {
	EVENT, # must go interact with event
	RETURN, # must return to settlement,
}

enum Dialog {
	PROMPT,
	ACCEPT,
	DECLINE,
	UNFINISH,
	FINISH,
}

var quest_id

var event : Event
var _event_id # the id of the related event (from the quest category ONLY)
var deliver_items = {} # items and amounts {item_id: amount} that must be brought to event tile
var quest_giver : Feature # the settlement that gave this quest
var return_items = {} #  items and amounts {item_id: amount} that must be brought back to settlement

var name = ""
var description = ""

var rewards = {} # the dict of item ids that this quest rewards and amounts

var _status = Status.EVENT


# initialise quest with its independent data
func init(_quest_id, data):
	quest_id = _quest_id
	
	_event_id = data["event_id"]
	deliver_items = data["deliver_items"]
	return_items = data["return_items"]
	
	rewards = data["rewards"]
	
	name = data["name"]
	description = data["description"]


# activate quest and set its context specific info (quest_giver and generate event)
func start(settlement_entity):
	quest_giver = settlement_entity
	
	if _event_id != null: # if an event was specified, generate it and set correct state
		event = Global.generate_event(Global.get_event_data(_event_id, Global.EventTypes.QUEST))
		event.set_associated_quest(self)
		event.toggle_warning()
	else:
		_status = Status.RETURN


func _on_feature_interacted(feature_entity : Feature):
	if not can_advance():
		return
	if _status == Status.EVENT: # if current goal is to visit event
		if feature_entity is Event and feature_entity.data.event_id == _event_id:
			# TODO: remove all deliver items from inventory
			if can_advance():
				_status = Status.RETURN
				print("interacted with event")
	elif _status == Status.RETURN: # if current goal is to return to settlement
		if feature_entity == quest_giver:
			if can_advance():
				print("interacted with settlement")
				# TODO: remove all deliver items from inventory


# returns whether quest can advance progress (mainly if it has the required items)
func can_advance() -> bool:
	if _status == Status.EVENT:
		return deliver_items == null or _check_items(deliver_items)
	elif _status == Status.RETURN:
		return return_items == null or _check_items(return_items)
	return false


# check all required items
func _check_items(item_dict):
	for it in item_dict:
		var item : Item = InventoryManager.item_stats[it]
		var current_amount = InventoryManager.inventory.get_item_amount(item.type, it)
		if current_amount < item_dict[it]:
			return false
	return true


func get_status() -> int:
	return _status


func get_dialogue(type):
	var label = ""
	match type:
		Dialog.PROMPT:
			label = "prompt_dialogue"
		Dialog.ACCEPT:
			label = "accept_dialogue"
		Dialog.DECLINE:
			label = "decline_dialogue"
		Dialog.UNFINISH:
			label = "unfinish_dialogue"
		Dialog.FINISH:
			label = "finish_dialogue"
	if label == "":
		return ""
	return Global.get_text_from_file(Global.Text.QUESTS, "quests.json", [quest_id, label]).duplicate()


func abandoned():
	if is_instance_valid(event):
		event.queue_free()
	var tmp = quest_giver.warning.get_text()
	if name in tmp:
		quest_giver.warning.toggle(false)

	quest_giver.set_next_quest()
	# this method should also try to remove any QUEST items related to the quest, but, frankly that is too much work and could cause problems
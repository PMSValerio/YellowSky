extends Resource


var quest_id

var event_id # the id of the related event (from the quest category ONLY)
var deliver_items = {} # items and amounts {item_id: amount} that must be brought to event tile
var quest_giver : Feature # the settlement that gave this quest
var return_items = {} #  items and amounts {item_id: amount} that must be brought back to settlement

var rewards = {} # the dict of item ids that this quest rewards and amounts

var _returning = true # false if still has to interact with event, true if only has to interact with settlement


func set_up(settlement_entity):
	var filepath = "quests.json"
	var data = Global.get_text_from_file(Global.Text.QUESTS, filepath, [quest_id])
	
	event_id = data["event_id"]
	deliver_items = data["deliver_items"]
	quest_giver = settlement_entity
	return_items = data["return_items"]
	
	rewards = data["rewards"]
	
	if event_id != null: # if an event was specified, generate it and set correct state
		EventManager.emit_signal("spawn_event_request", event_id, Global.EventTypes.QUEST)
		_returning = false


func _on_feature_interacted(feature_entity : Feature):
	if not _returning: # if current goal is to visit event
		if feature_entity is Event:
			if feature_entity.data.event_id == event_id:
				# TODO: remove all deliver items from inventory
				_returning = true
	elif feature_entity == quest_giver: # if current goal is to return to settlement
		# TODO: finish quest
		pass


# TODO: get dialogue: fetch from file each of three types

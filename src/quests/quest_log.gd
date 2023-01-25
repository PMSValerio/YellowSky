extends Node
class_name QuestLog

var _quest_log = {} # dictionary of all registered quests


# receive an uninitiated quest, register it, and start it, assigning its quest giver aka settlement
func regiter_new_quest(quest_data, settlement : Feature):
	if quest_data.quest_id in _quest_log: # sanity check
		print("ERROR: duplicate quest. If you see this message, you are a moron")
	else:
		_quest_log[quest_data.quest_id] = quest_data
		quest_data.start(settlement)


# remove a quest from log
func abandon_quest(quest_id):
	if has_quest(quest_id):
		_quest_log[quest_id].abandoned()
		_quest_log.erase(quest_id)


func has_quest(quest_id):
	return _quest_log.has(quest_id)


func get_quests():
	return _quest_log.values()


# return a type of dialogue lines
func get_dialogue(quest_id, type):
	if has_quest(quest_id):
		return _quest_log[quest_id].get_dialogue(type)


func on_feature_interacted(entity):
	for quest in _quest_log.values():
		quest._on_feature_interacted(entity)

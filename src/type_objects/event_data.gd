extends Reference
class_name EventData

var event_id = ""
var type
var animation = ""
var title = ""
var flavour_text = ""
var item_updates = {} # dictionary of item ids and delta values


func init(_event_id, _type, _animation, _title, _flavour_text, _item_updates):
	event_id = _event_id
	type = _type
	animation = _animation
	title = _title
	flavour_text = _flavour_text
	item_updates = _item_updates


# apply all item rewards and quest updates
# not used
func solve() -> void:
	for item_key in item_updates:
		var _type = InventoryManager.item_stats[item_key].type
		InventoryManager.add_item(_type, item_key, item_updates[item_key])
	
	# TODO: quest updates? send signal

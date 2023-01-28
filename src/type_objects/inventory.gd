extends Resource
class_name Inventory


var inventory = {} # internal organization goes [type][item_id] = number of said item. 
#All items that are not in possession still exist, but have their ammount set to 0.


func init(inventory_id: String = ""):
	# have a dictionary for each compactable item type
	for t in Global.Items.values(): 
		inventory[t] = {}

	# populate inventory with each item initialized at 0
	for type in Global.Items.values():
		for id in InventoryManager.item_stats.keys():
			if InventoryManager.item_stats[id].type == type:
				inventory[type][id] = 0
			
	# populate inventory according to pre-determined layout, in case id exists
	if inventory_id in InventoryManager.inventory_layouts.keys():
		var temp_invent =  InventoryManager.inventory_layouts[inventory_id] 
		for item_id in temp_invent.keys():
			if item_id in InventoryManager.item_stats.keys():
				add_items(InventoryManager.item_stats[item_id].type, item_id, temp_invent[item_id])
	

# --- || Utility Funcs || ---


func get_inventory_keys() -> Array:
	return inventory.keys()


# returns all item_ids of a certain category present in inventory
func get_all_ids_of_type(type) -> Array:
	return inventory[type].keys() if type in inventory else []


func get_item_amount(type, id) -> int:
	if type in inventory.keys() and id in inventory[type].keys():
		return inventory[type][id]
	return -1

# returns array with all info on items that have more than 0 ammount. 
# returned array has the following structure: [[type, id, ammount], [type, id, ammount], ...]
func get_owned_items_info() -> Array:

	var owned_items_info= [] 
	var ammount = 0

	for type in Global.Items.values():
		for id in get_all_ids_of_type(type):
			ammount = get_item_amount(type, id)
			if ammount > 0:
				owned_items_info.append([type, id, ammount])

	return owned_items_info


func get_total_value() -> int:

	var total_value = 0
	var ammount = 0

	for type in Global.Items.values():
		for id in get_all_ids_of_type(type):
			ammount = get_item_amount(type, id)
			if ammount > 0:
				total_value += InventoryManager.item_stats[id].value * ammount
	
	return total_value


func use_item(type, item_id):
	if type in inventory and item_id in inventory[type] and inventory[type][item_id] > 0 and InventoryManager.item_stats[item_id].usable:
		inventory[type][item_id] -= 1
		EventManager.emit_signal("item_used", InventoryManager.item_stats[item_id])

# supports positive/negative values to add/remove
func add_items(type, item_id, ammount=1):
	if type in inventory:
		if not item_id in inventory[type] && ammount > 0:
			inventory[type][item_id] = ammount
		else:
			inventory[type][item_id] += ammount
			if inventory[type][item_id] < 0:
				inventory[type][item_id] = 0


func reset():
	for type in Global.Items.values():
		for id in get_all_ids_of_type(type):
			inventory[type][id] = 0
			
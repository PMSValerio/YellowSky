extends GridContainer


# populates up to 8 items in the grid from a dict of item ids and amounts
func populate_items(item_list : Dictionary):
	for i in range(item_list.size()):
		if i >= get_child_count(): # stop at the amount of grid slots max
			break
		var item_id = item_list.keys()[i]
		
		get_child(i).populate_data(InventoryManager.item_stats[item_id], item_list[item_id])

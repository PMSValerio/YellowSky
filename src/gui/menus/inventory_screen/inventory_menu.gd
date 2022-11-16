extends Control


onready var item_grid = $MarginContainer/HBoxContainer/GridManager/ItemGrid


func _ready():
	_populate_item_grid()


func _populate_item_grid():
	for item_id in InventoryManager.Items.values():
		if InventoryManager.inventory[item_id] > 0:
			var grid_item = TextureButton.new()
			grid_item.texture = InventoryManager.item_stats[item_id].texture
			
			item_grid.add_child(grid_item)
	
	

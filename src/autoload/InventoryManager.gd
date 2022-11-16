extends Node


enum Items {
	TEST,
}

var item_stats = {}

var inventory = {}


func _ready():
	var test_item = Item.new()
	test_item.init(Items.TEST, load("res://icon.png"), 5, 10)
	
	item_stats[Items.TEST] = test_item
	
	inventory[Items.TEST] = 0


func update_item_count(item_id, added_value):
	inventory[item_id] += added_value
	EventManager.emit_signal("update_item_count", item_id, inventory[item_id])

extends MarginContainer
class_name GridSlot

onready var button_node := $Button

var data : Item = null
var amount : int = -1


func populate_data(item_data : Item, item_amount : int) -> void:
	$Button/TextureRect.texture = item_data.texture
	data = item_data
	set_amount(item_amount)


func clear_data() -> void:
	$Button/TextureRect.texture = null
	data = null
	amount = -1
	$Button/Label.text = ""


func set_amount(item_amount) -> void:
	amount = item_amount
	$Button/Label.text = "x" + str(amount)

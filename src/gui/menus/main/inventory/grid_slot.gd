extends MarginContainer
class_name GridSlot

onready var button_node := $Button
onready var texture_node := $Button/TextureRect
onready var label_node := $Button/Label
onready var toggle_node := $Button/ColorRect


export var is_for_trade = false

var data : Item = null
var amount : int = -1
var temp_amount : int = -1
var is_selected = false setget set_is_selected
var has_tooltip = false setget set_has_tooltip

signal button_pressed(left_or_right_mouse)


func _ready():
	if is_for_trade:
		set_up_for_trade()

	var _v = button_node.connect("gui_input", self, "_on_button_gui_input") 


func set_up_for_trade():
	is_for_trade = true
	

func _on_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if temp_amount > 0 && (event.button_index == BUTTON_LEFT || event.button_index == BUTTON_MIDDLE):
			emit_signal("button_pressed", event.button_index)
		elif event.button_index == BUTTON_RIGHT && temp_amount < amount:
			emit_signal("button_pressed", event.button_index)


func populate_data(item_data : Item, item_amount : int) -> void:
	texture_node.texture = item_data.texture
	data = item_data
	button_node.data = data
	set_amount(item_amount)
	set_has_tooltip(true)


func clear_data() -> void:

	if is_for_trade:
		button_node.button_mask = BUTTON_MASK_LEFT | BUTTON_MASK_RIGHT | BUTTON_MASK_MIDDLE
	else:
		button_node.button_mask = BUTTON_MASK_LEFT

	texture_node.texture = null
	data = null
	button_node.data = null
	amount = -1
	label_node.text = ""
	set_has_tooltip(false)


func set_amount(item_amount) -> void:
	amount = item_amount
	temp_amount = amount
	label_node.text = "x" + str(amount)


func add_trade_amount(amount_to_add) -> void:

	temp_amount += amount_to_add
	var temp_string = "x" + str(temp_amount) + "    " + str(amount)

	if is_selected:
		set_is_selected(false)

	if temp_amount >= amount:
		temp_amount = amount
		temp_string = "x" + str(amount)
	else:

		if temp_amount <= 0:
			temp_amount = 0
			set_is_selected(true)

	label_node.text = temp_string
			

func set_is_selected(new_value):
	is_selected = new_value
	toggle_node.visible = is_selected


func set_has_tooltip(new_value):
	if is_for_trade:
		has_tooltip = new_value
		if has_tooltip:
			button_node.hint_tooltip = "This will be replaced by custom grid_slot_tooltip, report if it doesn't."
		else:
			button_node.hint_tooltip = ""

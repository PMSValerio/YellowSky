extends Control

signal supply_pressed

onready var resource_icon = $ResourceIcon
onready var value_label = $ValueLabel

var type = null
var settlement_entity : Settlement = null


func init(new_type, settlement_ref) -> void:

	type = new_type
	if settlement_ref is Settlement:
		settlement_entity = settlement_ref

	resource_icon.init(type, 32)
	value_label.text = str(settlement_entity.resources[type])


func update_value():
	value_label.text = str(settlement_entity.resources[type])


func _on_SupplyButton_pressed():
	emit_signal("supply_pressed")

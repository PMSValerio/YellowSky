extends Control

signal supply_pressed

onready var supply_button = $SupplyButton
onready var type_label = $TypeLabel
onready var value_label = $ValueLabel

var type = ""
var settlement_entity : Settlement = null


func init(new_type, settlement_ref) -> void:
	type = new_type
	if settlement_ref is Settlement:
		settlement_entity = settlement_ref

	type_label = str(type)
	value_label = str(settlement_entity.resources[type])


func update_value():
	value_label = str(settlement_entity.resources[type])


func _on_SupplyButton_pressed():
	emit_signal("supply_pressed")



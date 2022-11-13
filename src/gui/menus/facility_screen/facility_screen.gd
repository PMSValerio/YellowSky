extends Control


var facility_entity = null # the actual facility node

onready var resources = Global.get_player().get_node("ResourceManager") # <- this is very bad, Resource should be global, maybe?


# this already assumes the player has enough resources for the operation
func _repair_by_amount(amount):
	if facility_entity != null:
		resources.add_to_resource(Global.Resources.MATERIALS, - amount)
		facility_entity.repair(amount)


# deposit amount of fuel; NOTE: this supports only one fuel type
func _deposit_fuel(amount):
	if facility_entity != null:
		for f in facility_entity.fuels.keys():
			resources.add_to_resource(f, -amount)
			facility_entity.fuels[f] += amount # TODO: change this into a better function call to facility


# update both facility and player resources
func _collect_products():
	if facility_entity != null:
		resources.add_to_resource(facility_entity.product_type, facility_entity.stored)
		facility_entity.collect()


func set_context(context):
	if context is Feature: # close enough
		facility_entity = context


func _on_ExitButton_pressed() -> void:
	EventManager.emit_signal("pop_menu")


# || --- TEMPORARY --- ||


func _on_Repair_pressed() -> void:
	var amount = facility_entity.max_health - facility_entity.health
	if amount > 0:
		_repair_by_amount(amount)
	else:
		print("already repaired")


func _on_Deposit_pressed() -> void:
	if facility_entity.health > 0:
		_deposit_fuel(50)
	else:
		print("facility must first be repaired")


func _on_Collect_pressed() -> void:
	if facility_entity.health > 0:
		_collect_products()
	else:
		print("facility must first be repaired")

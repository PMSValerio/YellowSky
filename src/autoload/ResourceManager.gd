extends Node

var _water = 0 setget set_water
var _materials = 0 setget set_materials 
var _energy = 0 setget set_energy
var _seeds = 0 setget set_seeds


func _ready():
	var _v = EventManager.connect("item_used", self, "_on_item_used")


# Sets
func set_water(new_val):
	_water = new_val
	EventManager.emit_signal("resource_changed", Global.Resources.WATER, _water)
	
func set_materials(new_val):
	_materials = new_val
	EventManager.emit_signal("resource_changed", Global.Resources.MATERIALS, _materials)

func set_energy(new_val):
	_energy = new_val
	EventManager.emit_signal("resource_changed", Global.Resources.ENERGY, _energy)

func set_seeds(new_val):
	_seeds = new_val
	EventManager.emit_signal("resource_changed", Global.Resources.SEEDS, _seeds)


func add_to_resource(type, amount):
	match type:
		Global.Resources.WATER:
			set_water(_water + amount)
		Global.Resources.MATERIALS:
			set_materials(_materials + amount)
		Global.Resources.ENERGY:
			set_energy(_energy + amount)
		Global.Resources.SEEDS:
			set_seeds(_seeds + amount)
		Global.Resources.FOOD:
			# fetch from a pool of possible facility food items and add them to inventory
			print("Collected food")


func get_resource(type) -> int:
	match type:
		Global.Resources.WATER:
			return _water
		Global.Resources.MATERIALS:
			return _materials
		Global.Resources.ENERGY:
			return _energy
		Global.Resources.SEEDS:
			return _seeds
	return -1


# used only for decompacting resource items
func _on_item_used(item_data : Item):
	if item_data.type == Global.Items.RESOURCES:
		add_to_resource(item_data.subtype, item_data.stat) # TODO: apply penalty

extends Node

signal water_changed(water_val)
signal craft_mat_changed(craft_mat_val)
signal energy_changed(energy_val)
signal seeds_changed(seeds_val)

var _water = 0 setget set_water
var _craft_mat = 0 setget set_craft_mat
var _energy = 0 setget set_energy
var _seeds = 0 setget set_seeds

var my_timer = Timer.new()

func _ready():
	my_timer.connect("timeout", self, "increase_all")
	my_timer.wait_time = 1.0
	my_timer.one_shot = false
	add_child(my_timer)
	my_timer.start()
	
	var _v = EventManager.connect("item_used", self, "_on_item_used")


func increase_all():
	set_water(_water + 1)
	set_craft_mat(_craft_mat + 1)
	set_energy(_energy + 1)
	set_seeds(_seeds + 1)

# sets
func set_water(new_val):
	_water = new_val
	emit_signal("water_changed", _water)
	
func set_craft_mat(new_val):
	_craft_mat = new_val
	emit_signal("craft_mat_changed", _craft_mat)

func set_energy(new_val):
	_energy = new_val
	emit_signal("energy_changed", _energy)

func set_seeds(new_val):
	_seeds = new_val
	emit_signal("seeds_changed", _seeds)


func add_to_resource(rec_id : int, amount : int):
	match rec_id:
		Global.FacilityResources.WATER:
			set_water(_water + amount)
		Global.FacilityResources.MATERIALS:
			set_craft_mat(_craft_mat + amount)
		Global.FacilityResources.ENERGY:
			set_energy(_energy + amount)
		Global.FacilityResources.SEEDS:
			set_seeds(_seeds + amount)


func get_resource(rec_id) -> int:
	match rec_id:
		Global.FacilityResources.WATER:
			return _water
		Global.FacilityResources.MATERIALS:
			return _craft_mat
		Global.FacilityResources.ENERGY:
			return _energy
		Global.FacilityResources.SEEDS:
			return _seeds
	return -1


# used only for decompacting resource items
func _on_item_used(item_data : Item):
	if item_data.type == Global.Items.RESOURCES:
		add_to_resource(item_data.subtype, item_data.stat) # TODO: apply penalty

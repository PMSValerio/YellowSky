extends Feature
class_name Facility

# these are only important for the facilities current operation status, regardless of type
enum Status {
	WRECKED, # destroyed state, health reached 0 and must be replenished fully before operation can begin
	NO_FUEL, # out of one of the fuels, so can't operate
	OFF, # player turned it off
	FULL, # one or more products is at full capacity, meaning it can't operate efficiently
	OK, # operating normally
}

onready var tooltip = $Tooltip
onready var sprite = $Sprite
onready var anim = $AnimationPlayer

var facility_type : FacilityType = null

# stats (might be modified by upgrades)
var max_health = 100.0 # (% for now)
var max_fuel = 100.0 # max fuel capacity for all fuels
var max_prod = 100.0 # max storage capacity

var health = 0.0
var fuels = {}
var stored = 0.0

var running = true

var _update_step = 0 # timer counter for update
var _is_destroyed = true # if destroyed, health must be replenished fully before it can operate again


func _ready() -> void:
	set_type(Global.facility_types.keys()[0])


func _process(delta: float) -> void:
	if _update_step >= Global.UPDATE_FREQ:
		_update_step = 0
		_tick()
	else:
		_update_step += delta


func _physics_process(_delta: float) -> void:
	# this is done so that the tooltip's scale isn't affected by perspective warping, only the position
	# still don't know what's better, add Tootip as child of Sprite instead to warp scale as well
	tooltip.position = sprite.position + Vector2(0, -64) * sprite.scale


# update facility stats
func _tick() -> void:
	if _can_operate():
		# consume fuel per update
		_operate_cost()
		# update stored resource
		if stored < max_prod:
			stored = min(max_prod, stored + facility_type.production_rate)
			if stored == max_prod:
				print("Facility full")
				pass # alert facility full
	
	var dict = fuels.duplicate()
	dict["stored"] = stored
	dict["health"] = health
	tooltip.update_items(dict)
	
	# TODO: remove
	tooltip.visible = true


# update state according to operation costs
func _operate_cost():
	for f in fuels.keys():
		fuels[f] = max(0, fuels[f] - facility_type.consumption_rate)
		if fuels[f] == 0:
			# alert facility power off
			print("Facility switching off")
			toggle_facility(false)


# can only operate if it wasn't destroyed and if it has fuel
func _can_operate():
	return get_status() in [Status.FULL, Status.OK]


func toggle_tooltip(toggle: bool) -> void:
	tooltip.visible = toggle


func get_status():
	if _is_destroyed or not facility_type.product_type in Global.FacilityResources.values():
		return Status.WRECKED
	for f in fuels.keys():
		if fuels[f] <= 0:
			return Status.NO_FUEL
	if not running:
		return Status.OFF
	if stored >= max_prod:
		return Status.FULL
	return Status.OK


# --- || Get Stats || ---


func get_max_health(_base : bool = false) -> float:
	return facility_type.max_health


func get_max_fuel(_base : bool = false) -> float:
	return facility_type.max_fuel


func get_max_prod(_base : bool = false) -> float:
	return facility_type.max_prod


func get_consumption_rate(_base : bool = false) -> float:
	return facility_type.consumption_rate


func get_production_rate(_base : bool = false) -> float:
	return facility_type.production_rate


# --- || Operation || ---


# function for turning facility on/off, changing visuals and other stuff
func toggle_facility(on_off) -> void:
	running = on_off
	# TODO: graphics update, signals?


func set_type(type):
	stored = 0
	if type in Global.facility_types.keys():
		facility_type = Global.facility_types[type]
		
		fuels.clear()
		for f in facility_type.fuel_types:
			fuels[f] = 0
		
		anim.play(str(facility_type.base_animation) + "_start")


func repair(amount):
	health = clamp(health + amount, 0.0, max_health)
	if health >= max_health:
		_is_destroyed = false
	elif health <= 0.0:
		_is_destroyed = true


func refuel(amount, resource):
	if resource in fuels.keys():
		fuels[resource] = clamp(fuels[resource], fuels[resource] + amount, max_fuel)


func collect():
	stored = 0


func interact() -> void:
	EventManager.emit_signal("push_menu", Global.Menus.FACILITY_MENU, self)

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

onready var tooltip = $FacilityTooltip
onready var sprite = $Sprite
onready var anim = $AnimationPlayer
onready var healthbar_anchor = $Node2D
onready var healthbar = $Node2D/ProgressBar

var facility_type : FacilityType = null

var health = 0.0
var fuels = {}
var products = {}

var upgrades_progress = {
	Global.FacilityUpgrades.INTEGRITY: -1,
	Global.FacilityUpgrades.CONS_RATE: -1,
	Global.FacilityUpgrades.PROD_RATE: -1,
	Global.FacilityUpgrades.ENV_FRIENDLY: -1,
}

var running = true

var _update_step = 0 # timer counter for update
var _is_destroyed = true # if destroyed, health must be replenished fully before it can operate again
var _last_status = Status.WRECKED


func _ready() -> void:
	set_type(Global.facility_types.keys()[0])
	var _v = EventManager.connect("disaster_damage", self, "_on_disaster_damage")


func _process(delta: float) -> void:
	if _update_step >= Global.UPDATE_FREQ:
		_update_step = 0
		_tick()
	else:
		_update_step += delta


func _physics_process(_delta: float) -> void:
	tooltip.position = sprite.position + Vector2(0, -32) * sprite.scale
	healthbar_anchor.position = sprite.position + Vector2(0, 16) * sprite.scale


# update facility stats
func _tick() -> void:
	if _can_operate():
		# consume fuel per update
		_operate_cost()
		
		var prod_rate = get_production_rate()
		# update stored resource
		for p in products.keys():
			if products[p] < get_max_prod():
				products[p] = min(get_max_prod(), products[p] + prod_rate)
				if products[p] == get_max_prod():
					warning.set_type(Global.Warnings.FULL)
					warning.toggle(true)
	
		if tooltip.visible:
			tooltip.update_items(self)
	healthbar_anchor.visible = sprite.visible and health < get_max_health()
	
	if _last_status != Status.OK and get_status() == Status.OK:
		_play_anim("_start")
	elif _last_status == Status.OK and get_status() != Status.OK:
		_play_anim("_end")
	_last_status = get_status()


# update state according to operation costs
func _operate_cost():
	var cons_rate = get_consumption_rate()
	for f in fuels.keys():
		fuels[f] = max(0, fuels[f] - cons_rate)
		if fuels[f] == 0:
			# alert facility power off
			warning.set_type(Global.Warnings.NO_FUEL)
			warning.toggle(true)


# can only operate if it wasn't destroyed and if it has fuel
func _can_operate():
	return get_status() in [Status.OK]


func toggle_tooltip(toggle: bool) -> void:
	tooltip.visible = toggle


func get_status():
	if _is_destroyed or facility_type.type_id == Global.FacilityTypes.WRECKED:
		return Status.WRECKED
	for f in fuels.keys():
		if fuels[f] <= 0:
			return Status.NO_FUEL
	if not running:
		return Status.OFF
	for p in products.keys():
		if products[p] >= get_max_prod():
			return Status.FULL
	return Status.OK


func _update_healthbar() -> void:
	healthbar.max_value = get_max_health()
	healthbar.value = health


# --- || Get Stats || ---


func get_max_health(_base : bool = false) -> float:
	return facility_type.max_health * get_upgrade_multiplier(Global.FacilityUpgrades.INTEGRITY)


func get_max_fuel(_base : bool = false) -> float:
	return facility_type.max_fuel


func get_max_prod(_base : bool = false) -> float:
	return facility_type.max_prod


func get_consumption_rate(_base : bool = false) -> float:
	return facility_type.consumption_rate * get_upgrade_multiplier(Global.FacilityUpgrades.CONS_RATE)


func get_production_rate(_base : bool = false) -> float:
	return facility_type.production_rate * get_upgrade_multiplier(Global.FacilityUpgrades.PROD_RATE)


func get_upgrade_multiplier(upgrade_type) -> float:
	var mult = 1.0
	var level = upgrades_progress[upgrade_type]
	var max_level = Global.get_facility_upgrade_field(upgrade_type, "max_level")
	if level >= 0 and level < max_level:
		mult = Global.get_facility_upgrade_field(upgrade_type, "multiplier", level)
	return mult


func has_eco_upgrade() -> bool:
	return facility_type.eco_upgrade != null


func advance_upgrade(upgrade_id) -> void:
	if upgrade_id in Global.FacilityUpgrades.values():
		upgrades_progress[upgrade_id] = min(upgrades_progress[upgrade_id] + 1, Global.get_facility_upgrade_field(upgrade_id, 'max_level') - 1)
		if upgrade_id == Global.FacilityUpgrades.ENV_FRIENDLY:
			if has_eco_upgrade():
				set_type(facility_type.eco_upgrade)
				WorldData.unlock_facility(facility_type.eco_upgrade)
				WorldData.facility_upgraded()
				ResourceManager.add_to_resource(Global.Resources.HOPE, Global.HOPE_PER_UPGRADE)


# --- || Operation || ---


# function for turning facility on/off, changing visuals and other stuff
func toggle_facility(on_off) -> void:
	running = on_off
	# TODO: graphics update, signals?


func set_type(type):
	if type in Global.facility_types.keys():
		facility_type = Global.facility_types[type]
		
		fuels.clear()
		for f in facility_type.fuel_types:
			fuels[f] = 0.0
		
		products.clear()
		for p in facility_type.product_types:
			products[p] = 0.0
		
		if get_status() == Status.OK:
			_play_anim("_start")
		else:
			_play_anim("_end")
			anim.seek(anim.current_animation_length)


func repair(amount):
	var old_status = get_status()
	health = clamp(health + amount, 0.0, get_max_health())
	if amount < 0 and old_status != Status.WRECKED:
		warning.set_type(Global.Warnings.F_DAMAGE)
		warning.toggle(true)
	else:
		warning.toggle(false)
	if health >= get_max_health():
		_is_destroyed = false
	else:
		if health <= 0.0:
			_is_destroyed = true
			if old_status != Status.WRECKED:
				warning.set_type(Global.Warnings.F_CRITICAL)
				warning.toggle(true)
	_update_healthbar()


func refuel(amount, resource):
	if resource in fuels.keys():
		fuels[resource] = clamp(fuels[resource], fuels[resource] + amount, get_max_fuel())
		tooltip.update_items(self)


func collect(resource):
	if resource in products.keys():
		products[resource] = 0.0 
		tooltip.update_items(self)


func _play_anim(state : String):
	if facility_type.type_id == Global.FacilityTypes.WRECKED:
		anim.play(facility_type.base_animation + "_start")
	else:
		anim.play(facility_type.base_animation + state)


func interact() -> void:
	EventManager.emit_signal("push_menu", Global.Menus.FACILITY_MENU, self)
	tooltip.visible = false
	warning.toggle(false)


func mouse_entered() -> void:
	var status = get_status()
	if sprite.visible and status in [Status.OK, Status.FULL, Status.NO_FUEL, Status.OFF]:
		tooltip.visible = true
		tooltip.update_items(self)


func mouse_exited() -> void:
	tooltip.visible = false


func blackout():
	if fuels.has(Global.Resources.ENERGY):
		fuels[Global.Resources.ENERGY] = 0
		warning.set_type(Global.Warnings.NO_FUEL)
		warning.toggle(true)


func _on_disaster_damage(damage):
	repair(-damage)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == facility_type.base_animation + "_start":
		_play_anim("_on")


# || --- SAVING --- ||


func export_data() -> Dictionary:
	var data = {}
	
	data["position"] = global_position
	data["type"] = facility_type.type_id
	data["health"] = health
	data["products"] = products
	data["fuels"] = fuels
	# TODO: upgrades
	
	return data


func load_data(data : Dictionary):
	global_position = data["position"]
	set_type(data["type"])
	health = data["health"]
	products = data["products"]
	fuels = data["fuels"]
	_last_status = get_status()
	# TODO: upgrades

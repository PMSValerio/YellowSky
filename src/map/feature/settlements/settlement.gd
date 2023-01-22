extends Feature
class_name Settlement

onready var sprite = $Sprite
onready var anim = $AnimationPlayer
onready var healthbar_anchor = $Node2D
onready var healthbar = $Node2D/ProgressBar

var settlement_type : SettlementType = null
var inventory : Inventory = null 

var health = 0.0
var population = 50
var rank = 1

var resources = {}

var _update_step = 0 # timer counter for update
var _is_destroyed = true # if destroyed, health must be replenished fully before it can operate again


func _ready():
	

	# pick random settlement type
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var num = rng.randi_range(0, len(Global.settlement_types) - 1)
	settlement_type = Global.settlement_types[Global.settlement_types.keys()[num]]


	inventory = Inventory.new()
	inventory.init(settlement_type.inventory_id)

	var _v = EventManager.connect("disaster_damage", self, "_on_disaster_damage")


func _process(delta: float) -> void:
	if _update_step >= Global.UPDATE_FREQ:
		_update_step = 0
		_tick()
	else:
		_update_step += delta


func _physics_process(_delta: float) -> void:
	healthbar_anchor.position = sprite.position + Vector2(0, 16) * sprite.scale


# update settlement stats
func _tick() -> void:
	pass
	""" 	if !_is_destroyed:
		# consume fuel per update
		_operate_cost()
		# update stored resource
		for p in products.keys():
			if products[p] < get_max_prod():
				products[p] = min(get_max_prod(), products[p] + facility_type.production_rate)
				if products[p] == get_max_prod():
					print("Facility full")
					warning.set_tooltip_text("Facility Full! [Click to dismiss]")
					warning.set_type("full")
					warning.toggle(true)
	
	healthbar_anchor.visible = sprite.visible and health < get_max_health()
	
	if _last_status != Status.OK and get_status() == Status.OK:
		_play_anim("_start")
	elif _last_status == Status.OK and get_status() != Status.OK:
		_play_anim("_end")
	_last_status = get_status() """


# --- || Manage || ---


# update state according to operation costs
func _operate_cost():
	pass
	""" 	for f in fuels.keys():
		fuels[f] = max(0, fuels[f] - facility_type.consumption_rate)
		if fuels[f] == 0:
			# alert facility power off
			print("Facility switching off")
			warning.set_tooltip_text("Facility out of Fuel! [Click to dismiss]")
			warning.set_type("fuel")
			warning.toggle(true) """

func repair(_amount):
	pass
	""" 	var old_status = get_status()
	health = clamp(health + amount, 0.0, get_max_health())
	if amount < 0 and old_status != Status.WRECKED:
		warning.set_tooltip_text("Facility Damaged! [Click to dismiss]")
		warning.set_type("damage")
		warning.toggle(true)
	else:
		warning.toggle(false)
	if health >= get_max_health():
		_is_destroyed = false
	else:
		if health <= 0.0:
			_is_destroyed = true
			if old_status != Status.WRECKED:
				warning.set_tooltip_text("Facility Destroyed! [Click to dismiss]")
				warning.set_type("critical")
				warning.toggle(true)
	_update_healthbar() """


# --- || UI || ---


func _update_healthbar() -> void:
	#healthbar.max_value = get_max_health()
	healthbar.value = health


# --- || Signal Callbacks || ---


func interact() -> void :
	EventManager.emit_signal("push_menu", Global.Menus.SETTLEMENT_SCREEN, self)


func _on_disaster_damage(damage):
	repair(-damage)

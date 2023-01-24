extends Feature
class_name Settlement

# possible status for "resource_status" 
enum Status {
	EMPTY,
	OK,
}

onready var sprite = $Sprite
onready var warning = $Warning
onready var anim = $AnimationPlayer
onready var healthbar_anchor = $Node2D
onready var healthbar = $Node2D/ProgressBar

var settlement_type : SettlementType = null
var inventory : Inventory = null 

var portrait_texture = null

var health = 0.0
var max_health = 0.0
var population = 0
var current_npc = ""
var rank = 0 # rank 0 is equivalent to the settlement being destroyed. Once destroyed, it cannot be recovered
var resources = {}

var _update_step = 0 # timer counter for update
var resources_status = {} # holds info regarding availability of each resource using Status enum


func _ready():
	# pick random settlement type
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var num = rng.randi_range(0, len(Global.settlement_types) - 1)
	_initialize_with_type(Global.settlement_types[Global.settlement_types.keys()[num]])

	var _v = EventManager.connect("disaster_damage", self, "_on_disaster_damage")


func _initialize_with_type(type):
	settlement_type = type

	inventory = Inventory.new()
	inventory.init(settlement_type.inventory_id)
	health = settlement_type.max_health
	max_health = settlement_type.max_health
	population = settlement_type.starting_population
	current_npc = settlement_type.npc_id
	set_rank(settlement_type.starting_rank)
	resources = settlement_type.starting_resources

	for r in resources.keys():
		if resources[r] > 0:
			resources_status[r] = Status.OK
		else:
			resources_status[r] = Status.EMPTY


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
	if rank > 0:
		_operate_cost()
		_update_population()

		# if health is not max, dispend extra materials over time to restore health
		if health < max_health && resources["MATERIALS"] > 0:
			repair(settlement_type.health_regen_rate)
			resources["MATERIALS"] -= settlement_type.health_regen_rate

	healthbar_anchor.visible = sprite.visible and health < max_health


# --- || Manage || ---


func set_rank(new_rank):
	rank = clamp(new_rank, 0, settlement_type.max_rank)
	portrait_texture = Global.settlement_portraits[int(rank)]
	anim.play("rank" + str(rank))


func _operate_cost():
	for r in resources.keys():
		resources[r] = max(0, resources[r] - settlement_type.base_consumption_rate * population)
		if resources[r] == 0:
			resources_status[r] = Status.EMPTY
			warning.set_tooltip_text("Lacking resources! [Click to dismiss]")
			warning.set_type("fuel")
			warning.toggle(true)


func _update_population():

	var has_all_resources = true

	for r in resources:
		if resources[r] <= 0:
			has_all_resources = false

	if has_all_resources:
		population = min(population * settlement_type.base_ppl_growth_rate, settlement_type.max_population)
	else:
		population -= settlement_type.base_ppl_loss_rate
		population = min(population - settlement_type.base_ppl_loss_rate, 0)
		if population <= 0:
			set_rank(0)


# only supports positive values
func replenish_resource(type, amount):
	if type in resources.keys() && amount > 0:
		resources[type] = min(resources[type] + amount, settlement_type.max_resource) 
		resources_status[type] = Status.OK
		warning.toggle(false)


func repair(amount):
	
	health = clamp(health + amount, 0.0, max_health)

	if amount < 0 and rank > 0:
		warning.set_tooltip_text("Settlement Damaged! [Click to dismiss]")
		warning.set_type("damage")
		warning.toggle(true)

		if health <= 0:
			set_rank(0)
			warning.set_tooltip_text("Facility Destroyed! [Click to dismiss]")
			warning.set_type("critical")
			warning.toggle(true)
	else:
		warning.toggle(false)

	_update_healthbar()


# --- || UI || ---


func _update_healthbar() -> void:
	healthbar.max_value = max_health
	healthbar.value = health


# --- || Signal Callbacks || ---


func interact() -> void :
	EventManager.emit_signal("push_menu", Global.Menus.SETTLEMENT_SCREEN, self)


func _on_disaster_damage(damage):
	repair(-damage)

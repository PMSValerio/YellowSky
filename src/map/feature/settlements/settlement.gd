extends Feature
class_name Settlement

onready var tooltip = $SettlementTooltip
onready var sprite = $Sprite
onready var anim = $AnimationPlayer
onready var healthbar_anchor = $Node2D
onready var healthbar = $Node2D/ProgressBar

var settlement_type : SettlementType = null
var inventory : Inventory = null 

var portrait_texture = null

var health = 0.0
var population = 0
var math_population : float = 0 # needed for intermediate calculations since population is an int
var current_npc = ""
var rank = 0 # rank 0 is equivalent to the settlement being destroyed. Once destroyed, it cannot be recovered
var resources = {}
var quests = {} # matches quest ids with actual quest data structures
var active_quest : Quest = null 

var rng = null # used for several random based calculations
var _update_step = 2 # timer counter for update
var update_step_modifier = 0 # affects time between settlement ticks. INFO: It is only for debug
var is_missing_resources = false # used to prevent warning from popping up every tick without resources


func _ready():
	# pick random settlement type
	rng = RandomNumberGenerator.new()
	rng.randomize()
	var num = rng.randi_range(0, len(Global.settlement_types) - 1)
	_initialize_with_type(Global.settlement_types[Global.settlement_types.keys()[num]])

	var _v = EventManager.connect("disaster_damage", self, "_on_disaster_damage")


func _initialize_with_type(type):
	settlement_type = type

	inventory = Inventory.new()
	inventory.init(settlement_type.inventory_id)
	health = settlement_type.max_health
	population = settlement_type.starting_population
	math_population = population
	current_npc = settlement_type.npc_id
	set_rank(settlement_type.starting_rank)
	resources = settlement_type.starting_resources

	for id in settlement_type.quests:
		quests[id] = Global.get_quest_data(id)
	
	set_next_quest()


func _process(delta: float) -> void:
	if _update_step >= Global.UPDATE_FREQ + update_step_modifier:
		_update_step = 0
		_tick()
	else:
		_update_step += delta


func _physics_process(_delta: float) -> void:
	tooltip.position = sprite.position + Vector2(0, -32) * sprite.scale
	healthbar_anchor.position = sprite.position + Vector2(0, 16) * sprite.scale


# update settlement stats
func _tick() -> void:
	if rank > 0:
		_operate_cost()
		_update_population()

		# if health is not max, dispend extra materials over time to restore health
		if health < get_max_health() && resources[Global.Resources.MATERIALS] > 0:
			repair(settlement_type.health_regen_rate)
			resources[Global.Resources.MATERIALS] -= settlement_type.health_regen_rate

		if tooltip.visible:
			tooltip.update_items(self)

	healthbar_anchor.visible = sprite.visible and health < get_max_health()


# --- || Manage || ---


func set_rank(new_rank):
	rank = clamp(new_rank, 0, get_max_rank())
	portrait_texture = Global.settlement_portraits[int(rank)]
	anim.play("rank" + str(rank))


func set_next_quest():
	active_quest = null
	if quests.size() > 0:
		
		# sets and removes top quest from quests dictionary
		active_quest = quests.values()[0]
		quests.erase(quests.keys()[0])


func _operate_cost():
	for r in resources.keys():
		if settlement_type.resources_for_growth.has(r):
			resources[r] = max(0, int(resources[r] - settlement_type.base_consumption_rate * population))
		if resources[r] == 0:
			if !is_missing_resources:
				is_missing_resources = true
				warning.set_type(Global.Warnings.NO_FUEL, "Lacking resources!")
				warning.toggle(true)


func _update_population():

	var has_all_resources = true

	for r in resources:
		if settlement_type.resources_for_growth.has(r) && resources[r] <= 0:
			has_all_resources = false

	#TODO: streamline calculations. Magic numbers are only approximates since no balancing has been made yet
	if has_all_resources:
		# simulate births
		var additional_modifier = settlement_type.max_population - population
		additional_modifier = additional_modifier / 2
		math_population *= settlement_type.base_ppl_growth_rate

		if rng.randi_range(0, settlement_type.max_population) < population + additional_modifier:
			population = min(int(population + 1 + math_population * 0.017), settlement_type.max_population)

		# simulate deaths
		if rng.randi_range(0, settlement_type.max_population) < population:
			population = max(0, population - 1)
	else:
		population = max(population - settlement_type.base_ppl_loss_rate, 0)


	# adjust ranking based on population
	for i in range(get_max_rank()):
		if population > settlement_type.population_for_rank_up * i:
			set_rank(i + 1)

	if population <= 0:
		set_rank(0)


# only supports positive values
func replenish_resource(type, amount):
	if type in resources.keys() && amount > 0:
		# in case the settlement was missing this specific resource
		if resources[type] <= 0:
			is_missing_resources = false
			warning.toggle(false)

		ResourceManager.add_to_resource(type, -amount) # already assumes the player has enough
		resources[type] = min(resources[type] + amount, settlement_type.max_resource) 
	

func repair(amount):
	
	if rank > 0:
		health = clamp(health + amount, 0.0, get_max_health())

	if amount < 0 and rank > 0:
		warning.set_type(Global.Warnings.S_DAMAGE)
		warning.toggle(true)

		if health <= 0:
			set_rank(0)
			warning.set_type(Global.Warnings.S_CRITICAL)
			warning.toggle(true)
	else:
		warning.toggle(false)

	_update_healthbar()


# --- || UI || ---


func _update_healthbar() -> void:
	healthbar.max_value = get_max_health()
	healthbar.value = health


func toggle_tooltip(toggle: bool) -> void:
	tooltip.visible = toggle


# --- || Get Stats || ---


func get_max_health() -> float:
	return settlement_type.max_health


func get_max_rank() -> int:
	return settlement_type.max_rank


# --- || Signal Callbacks || ---


func interact() -> void :
	EventManager.emit_signal("push_menu", Global.Menus.SETTLEMENT_SCREEN, self)
	tooltip.visible = false
	warning.toggle(false)


func mouse_entered() -> void:
	if sprite.visible and rank > 0:
		tooltip.visible = true
		tooltip.update_items(self)


func mouse_exited() -> void:
	tooltip.visible = false


func _on_disaster_damage(damage):
	repair(-damage)

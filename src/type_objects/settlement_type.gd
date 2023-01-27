extends Reference
class_name SettlementType

var id = ""
var name = ""
var flavour_text = ""
var npc_id = ""
var inventory_id = ""
var portrait_texture = null

var starting_rank = 1
var starting_population = 50
var starting_resources = {}
var quests = [] # array of quest ids

# common to all settlements for the time being
var max_health = 100.0
var max_rank = 3 # rank depends on the population. Rank thresholds are equally distant from each other aka max_ppl/max_rank 
var max_population = 100
var max_resource = 400.0
var health_regen_rate = 1 # health is regenerated while there are materials stashed on the settlement
var population_for_rank_up = 0
var base_ppl_growth_rate = 1.01 # people prosper if all resource requirements are met
var base_ppl_loss_rate = 2 # people are lost if at least one resource is missing
var death_probability = 5 # people are lost if at least one resource is missing
var base_consumption_rate = 0.01
var resources_for_growth =[Global.Resources.FOOD, Global.Resources.WATER, Global.Resources.ENERGY] # not ideal I know


func init(_id, _name, _flavour_text, _npc_id, _inventory_id, _portrait_texture_path, _rank, _population, _resources, _quests) -> void:
	id = _id
	name = _name
	flavour_text = _flavour_text
	npc_id = _npc_id
	inventory_id = _inventory_id
	portrait_texture = load(_portrait_texture_path)
	starting_rank = _rank
	starting_population = _population
	starting_resources = _resources
	quests = _quests

	population_for_rank_up = int(max_population / max_rank)

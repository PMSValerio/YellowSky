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

# common to all settlements for the time being
var max_health = 100.0
var max_rank = 3
var max_population = 100
var health_regen_rate = 1
var base_ppl_growth_rate = 1.1
var base_ppl_loss_rate = 2
var base_consumption_rate = 0.1
var max_resource = 500.0


func init(_id, _name, _flavour_text, _npc_id, _inventory_id, _portrait_texture_path, _rank, _population, _resources) -> void:
	id = _id
	name = _name
	flavour_text = _flavour_text
	npc_id = _npc_id
	inventory_id = _inventory_id
	portrait_texture = load(_portrait_texture_path)
	starting_rank = _rank
	starting_population = _population
	starting_resources = _resources

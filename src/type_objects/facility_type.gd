extends Reference
class_name FacilityType

var type_id = Global.FacilityTypes.WRECKED
var type_name = ""
var flavour_text = ""
var fuel_types = []
var product_types = []
var base_animation = "wrecked" # the base animation name (must match the animations in the animation player)
var portrait_texture = null
var icon_texture = null

# later on
# var environmental = false
var max_health = 100.0
var max_fuel = 100.0
var max_prod = 100.0

var production_rate = 5.0 # TODO: change according to balancing
var consumption_rate = 2.0 # TODO: ditto


func init(_type_id, _name, _flavour_text, _fuel_types, _product_types, _base_animation, _portrait_texture_path, _icon_texture_path) -> void:
	type_id = _type_id
	type_name = _name
	flavour_text = _flavour_text
	product_types = _product_types
	fuel_types = _fuel_types
	base_animation = _base_animation
	portrait_texture = load(_portrait_texture_path)
	icon_texture = load(_icon_texture_path)


func init_stats(_max_health, _max_fuel, _max_prod, _consumption_rate, _production_rate) -> void:
	max_health = _max_health
	max_fuel = _max_fuel
	max_prod = _max_prod
	production_rate = _production_rate
	consumption_rate = _consumption_rate

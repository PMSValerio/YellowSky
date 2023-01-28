extends Node2D

onready var population = $PanelContainer/VBoxContainer/PopulationContainer/PopulationValue
onready var food = $PanelContainer/VBoxContainer/FoodContainer/FoodLabel
onready var water = $PanelContainer/VBoxContainer/WaterContainer/WaterLabel
onready var energy = $PanelContainer/VBoxContainer/EnergyContainer/EnergyLabel
onready var materials = $PanelContainer/VBoxContainer/MaterialsContainer/MaterialsLabel


func _ready():
	$PanelContainer/VBoxContainer/FoodContainer/ResourceIcon.init(Global.Resources.FOOD, 32)
	$PanelContainer/VBoxContainer/WaterContainer/ResourceIcon.init(Global.Resources.WATER, 32)
	$PanelContainer/VBoxContainer/EnergyContainer/ResourceIcon.init(Global.Resources.ENERGY, 32)
	$PanelContainer/VBoxContainer/MaterialsContainer/ResourceIcon.init(Global.Resources.MATERIALS, 32)


func update_items(settlement_entity : Settlement):
	population.text = str(settlement_entity.population)
	food.text = str(settlement_entity.resources[Global.Resources.FOOD])
	water.text = str(settlement_entity.resources[Global.Resources.WATER])
	energy.text = str(settlement_entity.resources[Global.Resources.ENERGY])
	materials.text = str(settlement_entity.resources[Global.Resources.MATERIALS])

extends Node2D

onready var settle_name = $PanelContainer/VBoxContainer/NameLabel
onready var population = $PanelContainer/VBoxContainer/PopulationContainer/PopulationValue
onready var water = $PanelContainer/VBoxContainer/WaterContainer/WaterLabel
onready var energy = $PanelContainer/VBoxContainer/EnergyContainer/EnergyLabel
onready var materials = $PanelContainer/VBoxContainer/MaterialsContainer/MaterialsLabel


func _ready():
	$PanelContainer/VBoxContainer/WaterContainer/ResourceIcon.init(Global.Resources.WATER, 32)
	$PanelContainer/VBoxContainer/EnergyContainer/ResourceIcon.init(Global.Resources.ENERGY, 32)
	$PanelContainer/VBoxContainer/MaterialsContainer/ResourceIcon.init(Global.Resources.MATERIALS, 32)


func update_items(settlement_entity : Settlement):
	settle_name.text = settlement_entity.settlement_type.name
	population.text = str(settlement_entity.population)
	water.text = str(settlement_entity.resources[Global.Resources.WATER])
	energy.text = str(settlement_entity.resources[Global.Resources.ENERGY])
	materials.text = str(settlement_entity.resources[Global.Resources.MATERIALS])

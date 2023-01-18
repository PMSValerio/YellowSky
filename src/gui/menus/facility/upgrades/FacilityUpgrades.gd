extends Control

var facility_entity : Facility = null # the actual facility node
#Description label
onready var description_label = get_node("DownSection/PanelContainer/Descprition_Cost/HBoxContainer2/UpDescription")
onready var cost_label = get_node("DownSection/PanelContainer/Descprition_Cost/HBoxContainer2/UpDescription")

#ProdRate Buttons
onready var pr1 = get_node("PanelContainer/UpgradesSection/VBoxContainer/ProdRate/Button1")
const pr1_cost = 111
onready var pr2 = get_node("PanelContainer/UpgradesSection/VBoxContainer/ProdRate/Button2")
const pr2_cost = 112
onready var pr3 = get_node("PanelContainer/UpgradesSection/VBoxContainer/ProdRate/Button3")
const pr3_cost = 113
#MaxCapacity Buttons
onready var cr1 = get_node("PanelContainer/UpgradesSection/VBoxContainer/MaxCapcity/Button1")
const cr1_cost = 121
onready var cr2 = get_node("PanelContainer/UpgradesSection/VBoxContainer/MaxCapcity/Button2")
const cr2_cost = 122
onready var cr3 = get_node("PanelContainer/UpgradesSection/VBoxContainer/MaxCapcity/Button3")
const cr3_cost = 123
#Durability Buttons
onready var d1 = get_node("PanelContainer/UpgradesSection/VBoxContainer/Durability/Button1")
const d1_cost = 131
onready var d2 = get_node("PanelContainer/UpgradesSection/VBoxContainer/Durability/Button2")
const d2_cost = 132
onready var d3 = get_node("PanelContainer/UpgradesSection/VBoxContainer/Durability/Button3")
const d3_cost = 133
#Environmental friendly
onready var env = get_node("DownSection/PanelContainer2/Enviromental/MarginContainer/Env_Button")

func _ready():
	_connect_buttons()

func _connect_buttons():
	pr1.connect("pressed", self, "_on_button_pressed", [pr1])
	pr2.connect("pressed", self, "_on_button_pressed", [pr2])
	pr3.connect("pressed", self, "_on_button_pressed", [pr3])
	cr1.connect("pressed", self, "_on_button_pressed", [cr1])
	cr2.connect("pressed", self, "_on_button_pressed", [cr2])
	cr3.connect("pressed", self, "_on_button_pressed", [cr3])
	d1.connect("pressed", self, "_on_button_pressed", [d1])
	d2.connect("pressed", self, "_on_button_pressed", [d2])
	d3.connect("pressed", self, "_on_button_pressed", [d3])
	env.connect("pressed", self, "_on_env_pressed")

func set_context(context):
	if context is Feature:
		facility_entity = context

func _on_button_pressed(button):
	if button == pr1:
		print("#Upgrade ProdRate to lvl1")
		change_upgrade_info(button)
	elif button == pr2:
		print("#Upgrade ProdRate to lvl2")
		change_upgrade_info(button)
	elif button == pr3:
		print("#Upgrade ProdRate to lvl3")
		change_upgrade_info(button)
	elif button == cr1:
		print("#Upgrade MaxCapacity to lvl1")
		change_upgrade_info(button)
	elif button == cr2:
		print("#Upgrade MaxCapacity to lvl2")
		change_upgrade_info(button)
	elif button == cr3:
		print("#Upgrade MaxCapacity to lvl3")
		change_upgrade_info(button)
	elif button == d1:
		print("#Upgrade Durability to lvl1")
		change_upgrade_info(button)
	elif button == d2:
		print("#Upgrade Durability to lvl2")
		change_upgrade_info(button)
	elif button == d3:
		print("#Upgrade Durability to lvl3")
		change_upgrade_info(button)	

func change_upgrade_info(button):
	if button == pr1:
		description_label.text = "Lvl1 prodrate upgrade description"
		cost_label.text = str(pr1_cost) + "materials"
	elif button == pr2:
		description_label.text = "Lvl2 prodrate upgrade description"
		cost_label.text = str(pr2_cost) + "materials"
	elif button == pr3:
		description_label.text = "Lvl3 prodrate upgrade description"
		cost_label.text = str(pr3_cost) + "materials"
	elif button == cr1:
		description_label.text = "Lvl1 max capacity upgrade description"
		cost_label.text = str(cr1_cost) + "materials"
	elif button == cr2:
		description_label.text = "Lvl2 max capacity upgrade description"
		cost_label.text = str(cr2_cost) + "materials"
	elif button == cr3:
		description_label.text = "Lvl3 max capacity upgrade description"
		cost_label.text = str(cr3_cost) + "materials"
	elif button == d1:
		description_label.text = "Lvl1 durability upgrade description"
		cost_label.text = str(d1_cost) + "materials"
	elif button == d2:
		description_label.text = "Lvl2 durability upgrade description"
		cost_label.text = str(d2_cost) + "materials"
	elif button == d3:
		description_label.text = "Lvl3 durability upgrade description"
		cost_label.text = str(d3_cost) + "materials"

func _on_env_pressed():
	print("Environmental friendly upgrade")

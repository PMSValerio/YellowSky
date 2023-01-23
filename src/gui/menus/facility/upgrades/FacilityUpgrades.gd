extends Control

var _selected_upgrade_type = null
var facility_entity : Facility = null # the actual facility node
#Description label
onready var description_label = $PanelContainer/UpgradesSection/VBoxContainer/PanelContainer/Descprition_Cost/HBoxContainer2/UpDescription
onready var cost_label = $PanelContainer/UpgradesSection/VBoxContainer/PanelContainer/Descprition_Cost/HBoxContainer/UpgradeCost2

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
onready var env = get_node("PanelContainer/UpgradesSection/VBoxContainer/HBoxContainer/Enviromental")
onready var upgrade_btn = $PanelContainer/UpgradesSection/VBoxContainer/PanelContainer/Descprition_Cost/HBoxContainer3/Button

func _ready():
	_connect_buttons()

func _connect_buttons():
	pr1.connect("pressed", self, "_change_upgrade_info", [pr1])
	pr2.connect("pressed", self, "_change_upgrade_info", [pr2])
	pr3.connect("pressed", self, "_change_upgrade_info", [pr3])
	cr1.connect("pressed", self, "_change_upgrade_info", [cr1])
	cr2.connect("pressed", self, "_change_upgrade_info", [cr2])
	cr3.connect("pressed", self, "_change_upgrade_info", [cr3])
	d1.connect("pressed", self, "_change_upgrade_info", [d1])
	d2.connect("pressed", self, "_change_upgrade_info", [d2])
	d3.connect("pressed", self, "_change_upgrade_info", [d3])
	env.connect("pressed", self, "_change_upgrade_info", [env])
	upgrade_btn.connect("pressed", self, "_upgrade") 

func set_context(context):
	if context is Feature:
		facility_entity = context
		_check_level()

func _change_upgrade_info(button):
	if button == pr1:
		_selected_upgrade_type = Global.FacilityUpgrades.PROD_RATE
		cost_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, "cost", 0))
		description_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, 'info_text', 0))
	elif button == pr2:
		_selected_upgrade_type = Global.FacilityUpgrades.PROD_RATE		
		cost_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, "cost", 1))
		description_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, 'info_text', 1))
	elif button == pr3:
		_selected_upgrade_type = Global.FacilityUpgrades.PROD_RATE		
		cost_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, "cost", 2))
		description_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, 'info_text', 2))
	elif button == cr1:
		_selected_upgrade_type = Global.FacilityUpgrades.CONS_RATE		
		cost_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, "cost", 0))
		description_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, 'info_text', 0))
	elif button == cr2:
		_selected_upgrade_type = Global.FacilityUpgrades.CONS_RATE		
		cost_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, "cost", 1))
		description_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, 'info_text', 1))
	elif button == cr3:
		_selected_upgrade_type = Global.FacilityUpgrades.CONS_RATE		
		cost_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, "cost", 2))
		description_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, 'info_text', 2))
	elif button == d1:
		_selected_upgrade_type = Global.FacilityUpgrades.INTEGRITY		
		cost_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, "cost", 0))
		description_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, 'info_text', 0))
	elif button == d2:
		_selected_upgrade_type = Global.FacilityUpgrades.INTEGRITY		
		cost_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, "cost", 1))
		description_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, 'info_text', 1))
	elif button == d3:
		_selected_upgrade_type = Global.FacilityUpgrades.INTEGRITY		
		cost_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, "cost", 2))
		description_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, 'info_text', 2))
	elif button == env:
		_selected_upgrade_type = Global.FacilityUpgrades.ENV_FRIENDLY
		cost_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, "cost", 0))
		description_label.text = str(Global.get_facility_upgrade_field(_selected_upgrade_type, 'info_text', 0))
	
func _check_level():
	_disable_buttons_prod_rate()
	_disable_buttons_consump_rate()
	_disable_buttons_durability()
	_disable_buttons_env_friendly()
	
func _upgrade():
	if _selected_upgrade_type != null:
		facility_entity.advance_upgrade(_selected_upgrade_type)
		_check_level()
		
func _disable_buttons_prod_rate():
	if facility_entity.upgrades_progress[Global.FacilityUpgrades.PROD_RATE] == -1:
		pr1.disabled = false
		pr2.disabled = true
		pr3.disabled = true
	elif facility_entity.upgrades_progress[Global.FacilityUpgrades.PROD_RATE] == 0:
		pr1.disabled = true
		pr2.disabled = false
		pr3.disabled = true
	elif facility_entity.upgrades_progress[Global.FacilityUpgrades.PROD_RATE] == 1:
		pr1.disabled = true
		pr2.disabled = true
		pr3.disabled = false
		
func _disable_buttons_consump_rate():
	if facility_entity.upgrades_progress[Global.FacilityUpgrades.CONS_RATE] == -1:
		cr1.disabled = false
		cr2.disabled = true
		cr3.disabled = true
	elif facility_entity.upgrades_progress[Global.FacilityUpgrades.CONS_RATE] == 0:
		cr1.disabled = true
		cr2.disabled = false
		cr3.disabled = true
	elif facility_entity.upgrades_progress[Global.FacilityUpgrades.CONS_RATE] == 1:
		cr1.disabled = true
		cr2.disabled = true
		cr3.disabled = false
		
func _disable_buttons_durability():
	if facility_entity.upgrades_progress[Global.FacilityUpgrades.INTEGRITY] == -1:
		d1.disabled = false
		d2.disabled = true
		d3.disabled = true
	elif facility_entity.upgrades_progress[Global.FacilityUpgrades.INTEGRITY] == 0:
		d1.disabled = true
		d2.disabled = false
		d3.disabled = true
	elif facility_entity.upgrades_progress[Global.FacilityUpgrades.INTEGRITY] == 1:
		d1.disabled = true
		d2.disabled = true
		d3.disabled = false
		
func _disable_buttons_env_friendly():
	if facility_entity.upgrades_progress[Global.FacilityUpgrades.ENV_FRIENDLY] == -1:
		env.disabled = false
	else:
		env.disabled = true
	

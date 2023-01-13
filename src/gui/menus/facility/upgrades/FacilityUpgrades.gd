extends Control

var facility_entity : Facility = null # the actual facility node

#Description Label
var description_label 

#ProdRate Buttons
var pr1
var pr2
var pr3
#MaxCapacity Buttons
var mc1
var mc2
var mc3
#Durability Buttons
var d1
var d2
var d3
# In the scene where you are calling the other scene
func _ready():
	pr1 = get_node("PanelContainer/UpgradesSection/VBoxContainer/ProdRate/Button1")
	pr1.connect("pressed", self, "_on_button_pressed", [pr1])
	pr2 = get_node("PanelContainer/UpgradesSection/VBoxContainer/ProdRate/Button2")
	pr2.connect("pressed", self, "_on_button_pressed", [pr2])
	pr3 = get_node("PanelContainer/UpgradesSection/VBoxContainer/ProdRate/Button3")
	pr3.connect("pressed", self, "_on_button_pressed", [pr3])
	mc1 = get_node("PanelContainer/UpgradesSection/VBoxContainer/MaxCapcity/Button1")
	mc1.connect("pressed", self, "_on_button_pressed", [mc1])
	mc2 = get_node("PanelContainer/UpgradesSection/VBoxContainer/MaxCapcity/Button2")
	mc2.connect("pressed", self, "_on_button_pressed", [mc2])
	mc3 = get_node("PanelContainer/UpgradesSection/VBoxContainer/MaxCapcity/Button3")
	mc3.connect("pressed", self, "_on_button_pressed", [mc3])
	d1 = get_node("PanelContainer/UpgradesSection/VBoxContainer/Durability/Button1")
	d1.connect("pressed", self, "_on_button_pressed", [d1])
	d2 = get_node("PanelContainer/UpgradesSection/VBoxContainer/Durability/Button2")
	d2.connect("pressed", self, "_on_button_pressed", [d2])
	d3 = get_node("PanelContainer/UpgradesSection/VBoxContainer/Durability/Button3")
	d3.connect("pressed", self, "_on_button_pressed", [d3])

func set_context(context):
	if context is Feature:
		facility_entity = context

func _on_button_pressed(button):
	if button == pr1:
		print("#Upgrade ProdRate to lvl1")
	elif button == pr2:
		print("#Upgrade ProdRate to lvl2")
	elif button == pr3:
		print("#Upgrade ProdRate to lvl3")
	elif button == mc1:
		print("#Upgrade MaxCapacity to lvl1")
	elif button == mc2:
		print("#Upgrade MaxCapacity to lvl2")
	elif button == mc3:
		print("#Upgrade MaxCapacity to lvl3")
	elif button == d1:
		print("#Upgrade Durability to lvl1")
	elif button == d2:
		print("#Upgrade Durability to lvl2")
	elif button == d3:
		print("#Upgrade Durability to lvl3")
		
func change_description(button):
	if button == pr1:
		pass
		
	
	


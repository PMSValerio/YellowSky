extends Node2D


onready var cons_rate = $PanelContainer/HBoxContainer/VBoxContainer/PanelContainer/ConsRate
onready var prod_rate = $PanelContainer/HBoxContainer/VBoxContainer2/PanelContainer/ProdRate

onready var fuels = $PanelContainer/HBoxContainer/VBoxContainer/Fuels
onready var prods = $PanelContainer/HBoxContainer/VBoxContainer2/Prods


func update_items(facility_entity : Facility):
	cons_rate.text = "- " + str(facility_entity.get_consumption_rate()) + "/sec" if facility_entity != null else ""
	prod_rate.text = "+ " + str(facility_entity.get_production_rate()) + "/sec" if facility_entity != null else ""
	
	if facility_entity != null:
		var fix = 0
		for f in facility_entity.fuels.keys():
			fuels.get_children()[fix].set_state(f, facility_entity.fuels[f])
			fuels.get_children()[fix].visible = true
			fix += 1
		while fix < fuels.get_child_count():
			fuels.get_children()[fix].visible = false
			fix += 1
		var pix = 0
		for p in facility_entity.products.keys():
			prods.get_children()[pix].set_state(p, facility_entity.products[p])
			prods.get_children()[pix].visible = true
			pix += 1
		while pix < prods.get_child_count():
			prods.get_children()[pix].visible = false
			pix += 1

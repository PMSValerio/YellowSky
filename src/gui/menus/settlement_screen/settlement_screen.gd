extends Control

# info
onready var settlement_image = $MainScreen/PanelContainer/HBoxContainer/InfoContainer/SettlementImageContainer/SettlementImage
onready var name_box = $MainScreen/PanelContainer/HBoxContainer/InfoContainer/SettlementDescriptionContainer/VBoxContainer/SettlementName
onready var description_box = $MainScreen/PanelContainer/HBoxContainer/InfoContainer/SettlementDescriptionContainer/VBoxContainer/SettlementDescription
# main options
onready var main_options = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/MainOptions
onready var talk_btn = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/MainOptions/TalkButton
onready var stats_btn = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/MainOptions/StatsButton
onready var trade_btn = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/MainOptions/TradeButton
onready var leave_btn = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/MainOptions/LeaveButton
# dialogue options
onready var dialogue_options = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/DialogueOptions
onready var accept_btn = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/DialogueOptions/AcceptButton
onready var decline_btn = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/DialogueOptions/DeclineButton
onready var goodbye_btn = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/DialogueOptions/GoodbyeButton
onready var dialogue_pntr = $MainScreen/PanelContainer/HBoxContainer/InfoContainer/SettlementDescriptionContainer/DialoguePointer
# stats
onready var stats_container = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/StatsContainer
onready var health_label = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/StatsContainer/HealthContainer/HealthValue
onready var population_label = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/StatsContainer/PopulationContainer/PopulationValue
onready var rank_label = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/StatsContainer/RankContainer/RankValue
onready var resource_infos = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/StatsContainer/ResourcesContainer
# one-offs
onready var trade_screen_ref = $TradeScreen
onready var resource_slider = $MainScreen/PanelContainer/ResourceSlider

enum Modes {
	MAIN,
	DIALOGUE,
	STATS,
}

var ui_mode_nodes = {} # matches enum Modes states with the root UI nodes associated with each state 
var resource_info_nodes = {} # matches resource types with each resource info node

export var text_speed = 0.01
var text_in_progress = false
var npc_text = []
var current_dialogue_branch = 0
var current_mode = Modes.MAIN
var text_file_ref = "npc_dialogue.json"
var silder_resource = Global.Resources.NONE
var settlement_entity : Settlement  = null # the actual settlement node


func _ready() -> void:
	# set text speed at which the dialogue scrolls
	description_box.get_node("Timer").wait_time = text_speed
	
	# set nodes on modes dictionary
	ui_mode_nodes[Modes.MAIN] = main_options
	ui_mode_nodes[Modes.DIALOGUE] = dialogue_options
	ui_mode_nodes[Modes.STATS] = stats_container

	# setup info resource_infos
	var all_infos = resource_infos.get_children()
	for i in range(all_infos.size()):
		resource_info_nodes[settlement_entity.resources.keys()[i]] = all_infos[i]
		all_infos[i].init(settlement_entity.resources.keys()[i], settlement_entity)
		all_infos[i].connect("supply_pressed", self, "_on_Supply_pressed", [settlement_entity.resources.keys()[i]])
		
	# setup stats
	health_label.text = str(settlement_entity.health)
	population_label.text = str(settlement_entity.population)
	rank_label.text = str(settlement_entity.rank)

	# disable option btns if settlement is destroyed. Interaction is still kept because it might be needed in the future
	if settlement_entity.rank <= 0:
		talk_btn.disabled = true
		stats_btn.disabled = true
		trade_btn.disabled = true

	change_mode(Modes.keys()[Modes.MAIN])
	trade_screen_ref.set_context(settlement_entity)


func set_context(_context) -> void:
	if _context is Settlement:
		settlement_entity = _context


func change_mode(new_mode):
	if new_mode in Modes:
		var new_m = Modes[new_mode]

		for mode in ui_mode_nodes.keys():
			if new_m == mode:
				ui_mode_nodes[mode].visible = true
			else:
				ui_mode_nodes[mode].visible = false

		if new_m == Modes.DIALOGUE:
			toggle_text(true)
		elif new_m == Modes.MAIN:
			toggle_text(false)
			
			if current_mode == Modes.DIALOGUE:
				current_dialogue_branch = 0
				settlement_image.get_node("AnimationPlayer").play_backwards("show_npc")

		current_mode = new_m


# --- || Dialogue || ---


func toggle_text(to_dialogue):

	accept_btn.visible = false
	decline_btn.visible = false
	goodbye_btn.visible = to_dialogue
	dialogue_pntr.visible = to_dialogue

	if to_dialogue:
		# play animation of npc fading in
		settlement_image.get_node("AnimationPlayer").play("show_npc")
		# set name of the npc
		name_box.text = Global.get_text_from_file(Global.Text.NPCS, text_file_ref, [settlement_entity.current_npc, "Name"])

		update_branch_text()
		next_line()
	else: # to main
		
		# set all of info container
		settlement_image.texture = settlement_entity.portrait_texture
		name_box.text = settlement_entity.settlement_type.name
		description_box.text = settlement_entity.settlement_type.flavour_text
		description_box.visible_characters = description_box.text.length()


func next_line():
	if npc_text.size() > 1:

		dialogue_pntr.get_node("AnimationPlayer").stop(false)
		text_in_progress = true
		# removes first dialogue line from npc_text, keeping the rest in case there are any
		description_box.text = npc_text.pop_front() 
		description_box.visible_characters = 0

		# scroll through letters, instead of displaying them all at once
		for _i in range(0, description_box.text.length()):
			if text_in_progress:
				description_box.visible_characters += 1
				description_box.get_node("Timer").start()
				yield(description_box.get_node("Timer"), "timeout")

		dialogue_pntr.get_node("AnimationPlayer").play("Active")
		text_in_progress = false

		# Check for end string at the end of each dialogue branch to setup appropriate behaviour
		if npc_text[0] == "Quest":
			quest_update(true, 0)
		elif npc_text[0] == "End":
			dialogue_pntr.visible = false
	else:
		# may want to do seomthing in here, potentially
		print("Finish")


func update_branch_text():
	npc_text = Global.get_text_from_file(Global.Text.NPCS, text_file_ref, [settlement_entity.current_npc, "Branches", str(current_dialogue_branch)]).duplicate()


func quest_update(show_quest_options, nmbr_to_advance_branch):
	accept_btn.visible = show_quest_options
	decline_btn.visible = show_quest_options
	dialogue_pntr.visible = !show_quest_options

	if !show_quest_options:
		current_dialogue_branch += nmbr_to_advance_branch
		update_branch_text()

	next_line()


# --- || Signal Callbacks || ---


func _on_TalkButton_pressed():
	change_mode(Modes.keys()[Modes.DIALOGUE])


func _on_StatsButton_pressed():
	change_mode(Modes.keys()[Modes.STATS])
	

func _on_TradeButton_pressed():
	trade_screen_ref.visible = true


func _on_LeaveButton_pressed():
	EventManager.emit_signal("pop_menu")


# Info Options
func _on_ExitBtn_pressed():
	change_mode(Modes.keys()[Modes.MAIN])


func _on_Supply_pressed (resource_type):
	resource_slider.set_state(ResourceManager.get_resource(resource_type), settlement_entity.resources[resource_type], settlement_entity.settlement_type.max_resource, Global.resource_icons[resource_type])
	resource_slider.visible = true
	silder_resource = resource_type


func _on_ResourceSlider_value_chosen(delta_value):
	settlement_entity.replenish_resource(silder_resource, delta_value)
	resource_info_nodes[silder_resource].update_value()


# Dialogue Options
func _on_AcceptButton_pressed():
	quest_update(false, 1)


func _on_DeclineButton_pressed():
	quest_update(false, 2)


func _on_GoodbyeButton_pressed():	
	change_mode(Modes.keys()[Modes.MAIN])


# clicking on text box to advance dialogue line
func _on_SettlementDescriptionContainer_gui_input(event:InputEvent):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1 && current_mode == Modes.DIALOGUE):
		# clicking while text is being displayed will instantly show the sucrrently scrolling text
		if text_in_progress:
			description_box.visible_characters = description_box.text.length()
			text_in_progress = false
		else:
			# if the scroll was already finished, attempt to show new line
			next_line()

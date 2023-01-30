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
onready var plant_btn = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/MainOptions/PlantButton
onready var sleep_btn = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/MainOptions/SleepButton
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
onready var green_tiles_label = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/StatsContainer/GreenTilesContainer/GTValue
onready var resource_infos = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/StatsContainer/ResourcesContainer
# one-offs
onready var trade_screen_ref = $TradeScreen
onready var resource_slider = $MainScreen/PanelContainer/ResourceSlider
onready var quest_completed_screen = $MainScreen/PanelContainer/QuestCompletedSCreen

onready var keyboard_sfx = $Keyboard_sfx
onready var bg_music_player = $BG_MusicPlayer

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
var current_dialogue_branch = 1
var current_mode = Modes.MAIN
var text_file_ref = "npc_dialogue.json"
var silder_resource = Global.Resources.NONE
var is_slider_active = false
var settlement_entity : Settlement  = null # the actual settlement node

var quest_completed = false # sanity check to guarantee that quest complete screen only appears when its supposed to 
var show_quest_reward = false


func _ready() -> void:
	# set text speed at which the dialogue scrolls
	description_box.get_node("Timer").wait_time = text_speed
	toggle_text_mode(false)
	bg_music_player.play()
	
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
		
	# setup base stats
	health_label.text = str(settlement_entity.health)
	population_label.text = str(settlement_entity.population)
	rank_label.text = str(settlement_entity.rank)
	green_tiles_label.text = str(settlement_entity.green_tiles) + "/" + str(settlement_entity.max_green_tiles)

	#setup sleep button
	sleep_btn.disabled = !settlement_entity.can_sleep

	# disable option btns if settlement is destroyed. Interaction is still kept because it might be needed in the future
	if settlement_entity.rank <= 0:
		talk_btn.disabled = true
		stats_btn.disabled = true
		trade_btn.disabled = true
		plant_btn.disabled = true
		sleep_btn.disabled = true

	change_mode(Modes.keys()[Modes.MAIN])
	trade_screen_ref.set_context(settlement_entity)


func set_context(_context) -> void:
	if _context is Settlement:
		settlement_entity = _context


func change_mode(new_mode):
	if new_mode in Modes:
		var new_m = Modes[new_mode]

		# disable all other options that dont belong to new_mode
		for mode in ui_mode_nodes.keys():
			if new_m == mode:
				ui_mode_nodes[mode].visible = true
			else:
				ui_mode_nodes[mode].visible = false

		# extra logic
		if new_m == Modes.DIALOGUE:
			toggle_text_mode(true)
		elif new_m == Modes.MAIN:
			toggle_text_mode(false)
			
			# reset other variables in case menu is changing from dialogue mode
			if current_mode == Modes.DIALOGUE:
				settlement_image.get_node("AnimationPlayer").play_backwards("show_npc" + str(settlement_entity.rank))

		current_mode = new_m


# --- || Dialogue || ---


func toggle_text_mode(to_dialogue):

	accept_btn.visible = false
	decline_btn.visible = false
	goodbye_btn.visible = to_dialogue
	dialogue_pntr.visible = to_dialogue

	if to_dialogue:
		settlement_image.get_node("AnimationPlayer").play("show_npc" + str(settlement_entity.rank))

		name_box.text = Global.get_text_from_file(Global.Text.NPCS, text_file_ref, [settlement_entity.current_npc, "Name"])
		npc_text = Global.get_text_from_file(Global.Text.NPCS, text_file_ref, [settlement_entity.current_npc, "Dialogue", str(current_dialogue_branch)]).duplicate()

		# only display quest dialogue if quest is ongoing
		if settlement_entity.active_quest != null:
			if WorldData.quest_log.has_quest(settlement_entity.active_quest.quest_id):
				check_for_quest()

		next_line()
	else: # to main
		
		# set all of info container
		settlement_image.texture = settlement_entity.portrait_texture
		name_box.text = settlement_entity.settlement_type.name
		description_box.text = settlement_entity.settlement_type.flavour_text
		description_box.visible_characters = description_box.text.length()


func next_line():
	if npc_text.size() > 1:

		dialogue_pntr.pause()
		text_in_progress = true
		
		# removes first dialogue line from npc_text, keeping the rest in case there are any
		description_box.text = npc_text.pop_front() 
		description_box.visible_characters = 0
		
		var parsed_string = description_box.text.replace(" ","")

		keyboard_sfx.play()
		# scroll through letters, instead of displaying them all at once
		for _i in range(parsed_string.length()):
			if text_in_progress:
				description_box.visible_characters += 1
				description_box.get_node("Timer").start()
				yield(description_box.get_node("Timer"), "timeout")

		keyboard_sfx.stop()
		dialogue_pntr.play()
		text_in_progress = false

		# check for keyword
		var keyword = -1
		if npc_text[0] in Global.TextKeywords.keys():
			keyword = Global.TextKeywords[npc_text[0]]

		# setup appropriate behaviour based on keyword found on end string
		match keyword:
			Global.TextKeywords.QUEST:
				check_for_quest()
			Global.TextKeywords.OPTIONS:
				manage_quest_options(true, false)
			Global.TextKeywords.REWARD:
				if quest_completed:
					quest_completed = false
					show_quest_reward = true
			Global.TextKeywords.END:
				dialogue_pntr.visible = false
				if settlement_entity.is_start_settle:
					current_dialogue_branch = 2
			

func check_for_quest():
	if settlement_entity.active_quest != null:
		if WorldData.quest_log.has_quest(settlement_entity.active_quest.quest_id):
			if settlement_entity.active_quest.can_advance() && settlement_entity.active_quest.get_status() == Quest.Status.RETURN:
				# quest completed
				npc_text = settlement_entity.active_quest.get_dialogue(Quest.Dialog.FINISH)
				quest_completed = true
			else:
				# still doesnt have the items
				npc_text = settlement_entity.active_quest.get_dialogue(Quest.Dialog.UNFINISH)
		else:
			# if the settlement is not waiting for a quest, display quest prompt
			npc_text = settlement_entity.active_quest.get_dialogue(Quest.Dialog.PROMPT)	
	else:
		# if no quest, is active, skip over keyword and continue dialogue
		npc_text.pop_front() 


func update_branch_text():
	npc_text = Global.get_text_from_file(Global.Text.NPCS, text_file_ref, ["settlement1", "NPC", "Branches", str(current_dialogue_branch)]).duplicate()


func show_quest_completed_screen():
	quest_completed_screen.set_context(settlement_entity.active_quest)
	quest_completed_screen.visible = true
	settlement_entity.active_quest.on_completion(settlement_entity)


func manage_quest_options(show_quest_options, did_accept):
	accept_btn.visible = show_quest_options
	decline_btn.visible = show_quest_options
	dialogue_pntr.visible = !show_quest_options

	if !show_quest_options:
		if did_accept:
			WorldData.quest_log.regiter_new_quest(settlement_entity.active_quest, settlement_entity)
			npc_text = settlement_entity.active_quest.get_dialogue(Quest.Dialog.ACCEPT)
		else:
			npc_text = settlement_entity.active_quest.get_dialogue(Quest.Dialog.DECLINE)

	next_line()


# --- || UI || ---


func show_slider(resource_type):
	if resource_type == Global.Resources.SEEDS:
		resource_slider.set_state(ResourceManager.get_resource(resource_type), 0, settlement_entity.settlement_type.seeds_per_tile * (settlement_entity.max_green_tiles - settlement_entity.green_tiles), Global.resource_icons[resource_type], "Settlement", settlement_entity.settlement_type.seeds_per_tile)
	else:
		resource_slider.set_state(ResourceManager.get_resource(resource_type), settlement_entity.resources[resource_type], settlement_entity.settlement_type.max_resource, Global.resource_icons[resource_type], "Settlement")

	resource_slider.visible = true
	is_slider_active = true
	silder_resource = resource_type


# --- || Signal Callbacks || ---


func _on_TalkButton_pressed():
	if !is_slider_active:
		change_mode(Modes.keys()[Modes.DIALOGUE])


func _on_StatsButton_pressed():
	if !is_slider_active:
		change_mode(Modes.keys()[Modes.STATS])
	

func _on_TradeButton_pressed():
	if !is_slider_active:
		trade_screen_ref.visible = true


func _on_PlantButton_pressed():
	if !is_slider_active:
		show_slider(Global.Resources.SEEDS)


func _on_SleepButton_pressed():
	if !is_slider_active:
		EventManager.emit_signal("attempt_sleep")
		settlement_entity.can_sleep = false
		EventManager.emit_signal("pop_menu")


func _on_LeaveButton_pressed():
	if !is_slider_active:
		EventManager.emit_signal("pop_menu")


# Info Options
func _on_ExitBtn_pressed():
	if !is_slider_active:
		change_mode(Modes.keys()[Modes.MAIN])


func _on_Supply_pressed (resource_type):
	if !is_slider_active:
		show_slider(resource_type)


func _on_ResourceSlider_value_chosen(delta_value):
	is_slider_active = false
	if silder_resource == Global.Resources.SEEDS:
		settlement_entity.plant_seeds(delta_value)
		green_tiles_label.text = str(settlement_entity.green_tiles) + "/" + str(settlement_entity.max_green_tiles)
	else:
		# actually supply resources to settlement and update menu
		settlement_entity.replenish_resource(silder_resource, delta_value)
		resource_info_nodes[silder_resource].update_value()


# Dialogue Options
func _on_AcceptButton_pressed():
	manage_quest_options(false, true)


func _on_DeclineButton_pressed():
	manage_quest_options(false, false)


func _on_GoodbyeButton_pressed():	
	change_mode(Modes.keys()[Modes.MAIN])


# clicking on text box to advance dialogue line
func _on_SettlementDescriptionContainer_gui_input(event:InputEvent):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1 && dialogue_pntr.visible):
		# clicking while text is being displayed will instantly show the currently scrolling text
		if text_in_progress:
			description_box.visible_characters = description_box.text.length()
			text_in_progress = false
		else:
			# if the scroll was already finished, clicking will show new line or quest end screen
			if show_quest_reward:
				show_quest_reward = false
				show_quest_completed_screen()
				npc_text.pop_front()
				return

			next_line()

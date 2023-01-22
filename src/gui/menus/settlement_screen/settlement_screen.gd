extends Control

onready var settlement_image = $MainScreen/PanelContainer/HBoxContainer/SettlementContainer/SettlementImageContainer/SettlementImage
onready var name_box = $MainScreen/PanelContainer/HBoxContainer/SettlementContainer/SettlementDescriptionContainer/VBoxContainer/SettlementName
onready var description_box = $MainScreen/PanelContainer/HBoxContainer/SettlementContainer/SettlementDescriptionContainer/VBoxContainer/SettlementDescription
onready var talk_btn = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/TalkButton
onready var trade_btn = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/TradeButton
onready var leave_btn = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/LeaveButton
onready var goodbye_btn = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/GoodbyeButton
onready var accept_btn = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/AcceptButton
onready var decline_btn = $MainScreen/PanelContainer/HBoxContainer/OptionsContainer/Options/DeclineButton
onready var dialogue_pntr = $MainScreen/PanelContainer/HBoxContainer/SettlementContainer/SettlementDescriptionContainer/DialoguePointer

onready var trade_screen_ref = $TradeScreen


export var text_speed = 0.01
var text_in_progress = false
var npc_text = []
var current_dialogue_branch = 0
var is_talking = false
var text_file_ref = "npc_dialogue.json"

var settlement_entity : Settlement  = null # the actual facility node
var has_set_trade = false # used to circumvent the fact that trade's "set_context" cant be set when the menu is pushed 


func _ready() -> void:
	description_box.get_node("Timer").wait_time = text_speed
	toggle_text_mode(false)


func set_context(context) -> void:
	settlement_entity = context


# --- || Dialogue || ---


func toggle_text_mode(to_npc):

	talk_btn.visible = !to_npc
	trade_btn.visible = !to_npc
	leave_btn.visible = !to_npc
	goodbye_btn.visible = to_npc
	dialogue_pntr.visible = to_npc

	if to_npc:
		is_talking = true
		settlement_image.get_node("AnimationPlayer").play("show_npc")

		name_box.text = Global.get_text_from_file(Global.Text.NPCS, text_file_ref, [settlement_entity.settlement_type.npc_id, "Name"])

		update_branch_text()
		next_line()
	else:
		if is_talking:
			settlement_image.get_node("AnimationPlayer").play_backwards("show_npc")

		is_talking = false
		accept_btn.visible = false
		decline_btn.visible = false

		name_box.text = settlement_entity.settlement_type.name
		description_box.text = settlement_entity.settlement_type.flavour_text
		description_box.visible_characters = description_box.text.length()


func next_line():
	if npc_text.size() > 1:

		dialogue_pntr.get_node("AnimationPlayer").stop(false)
		text_in_progress = true
		description_box.text = npc_text.pop_front() 

		description_box.visible_characters = 0

		# Scroll through letters, instead of displaying them all at once
		for _i in range(0, description_box.text.length()):
			if text_in_progress:
				description_box.visible_characters += 1
				description_box.get_node("Timer").start()
				yield(description_box.get_node("Timer"), "timeout")

		dialogue_pntr.get_node("AnimationPlayer").play("Active")
		text_in_progress = false

		# Check for end string at the end of each dialogue branch to setup appropriate behaviour
		if npc_text[0] == "Quest":
			quest_update(true)
		elif npc_text[0] == "End":
			dialogue_pntr.visible = false
	else:
		print("Finish")


func update_branch_text():
	npc_text = Global.get_text_from_file(Global.Text.NPCS, text_file_ref, [settlement_entity.settlement_type.npc_id, "Branches", str(current_dialogue_branch)]).duplicate()


func quest_update(show):
	accept_btn.visible = show
	decline_btn.visible = show
	dialogue_pntr.visible = !show

	if !show:
		update_branch_text()

	next_line()


# --- || Signal Callbacks || ---


func _on_TalkButton_pressed():
	toggle_text_mode(true)


func _on_TradeButton_pressed():
	if !has_set_trade:
		has_set_trade = true
		trade_screen_ref.set_context(settlement_entity)
	
	trade_screen_ref.visible = true


func _on_LeaveButton_pressed():
	EventManager.emit_signal("pop_menu")


# Dialogue Options
func _on_GoodbyeButton_pressed():
	current_dialogue_branch = 0
	toggle_text_mode(false)


func _on_AcceptButton_pressed():
	current_dialogue_branch += 1
	quest_update(false)


func _on_DeclineButton_pressed():
	current_dialogue_branch += 2
	quest_update(false)

# clicking on text box to advance dialogue line
func _on_SettlementDescriptionContainer_gui_input(event:InputEvent):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1 && is_talking):
		if text_in_progress:
			description_box.visible_characters = description_box.text.length()
			text_in_progress = false
		else:
			next_line()

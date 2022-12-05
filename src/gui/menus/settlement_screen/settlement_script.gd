extends Control

onready var settlement_image = $ColorRect/HBoxContainer/SettlementContainer/SettlementImageContainer/SettlementImage
onready var name_box = $ColorRect/HBoxContainer/SettlementContainer/SettlementDescriptionContainer/VBoxContainer/SettlementName
onready var description_box = $ColorRect/HBoxContainer/SettlementContainer/SettlementDescriptionContainer/VBoxContainer/SettlementDescription
onready var talk_btn = $ColorRect/HBoxContainer/OptionsContainer/Options/TalkButton
onready var trade_btn = $ColorRect/HBoxContainer/OptionsContainer/Options/TradeButton
onready var leave_btn = $ColorRect/HBoxContainer/OptionsContainer/Options/LeaveButton

# TODO: decide whether continue button stays or goes, since the pointer is also an option
onready var continue_btn = $ColorRect/HBoxContainer/OptionsContainer/Options/ContinueButton
onready var goodbye_btn = $ColorRect/HBoxContainer/OptionsContainer/Options/GoodbyeButton
onready var accept_btn = $ColorRect/HBoxContainer/OptionsContainer/Options/AcceptButton
onready var decline_btn = $ColorRect/HBoxContainer/OptionsContainer/Options/DeclineButton
onready var dialogue_pntr = $ColorRect/HBoxContainer/SettlementContainer/SettlementDescriptionContainer/DialoguePointer

export var text_speed = 0.01
var text_in_progress = false
var npc_text = []
var current_dialogue_branch = 0


func _ready() -> void:

	description_box.get_node("Timer").wait_time = text_speed
	toggle_text_mode(false)


func toggle_text_mode(to_npc):

	talk_btn.visible = !to_npc
	trade_btn.visible = !to_npc
	leave_btn.visible = !to_npc
	#continue_btn.visible = to_npc
	goodbye_btn.visible = to_npc
	dialogue_pntr.visible = to_npc

	if to_npc:
		settlement_image.get_node("AnimationPlayer").play("show_npc")
		name_box.text = TextManager.get_text(Global.Text.SETTLEMENTS, ["settlement1", "NPC", "Name"])

		update_branch_text()
		next_line()
	else:
		accept_btn.visible = false
		decline_btn.visible = false

		#TODO: find proper solution to prevent anim from playing on the first time the settlement menu opens up
		if npc_text.size() != 0:
			settlement_image.get_node("AnimationPlayer").play_backwards("show_npc")
		
		name_box.text = TextManager.get_text(Global.Text.SETTLEMENTS, ["settlement1", "Settlement", "Name"])
		description_box.text = TextManager.get_text(Global.Text.SETTLEMENTS, ["settlement1", "Settlement", "Description"])
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
			#continue_btn.visible = false
			dialogue_pntr.visible = false
	else:
		print("Finish")


func update_branch_text():
	npc_text = TextManager.get_text(Global.Text.SETTLEMENTS, ["settlement1", "NPC", "Branches", str(current_dialogue_branch)]).duplicate()


func quest_update(show):
	accept_btn.visible = show
	decline_btn.visible = show
	#continue_btn.visible = !show
	dialogue_pntr.visible = !show

	if !show:
		update_branch_text()

	next_line()

# Signal Stuff Below:::::::::::::::::::::::::::::::::::::::::::
func _on_TalkButton_pressed():
	toggle_text_mode(true)


func _on_LeaveButton_pressed():
	EventManager.emit_signal("pop_menu")


func _on_GoodbyeButton_pressed():
	current_dialogue_branch = 0
	toggle_text_mode(false)

# Dialogue Options
func _on_ContinueButton_pressed():
	if text_in_progress:
		description_box.visible_characters = description_box.text.length()
		text_in_progress = false
	else:
		next_line()


func _on_AcceptButton_pressed():
	current_dialogue_branch += 1
	quest_update(false)


func _on_DeclineButton_pressed():
	current_dialogue_branch += 2
	quest_update(false)


func _on_DialoguePointer_gui_input(event:InputEvent):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		if text_in_progress:
			description_box.visible_characters = description_box.text.length()
			text_in_progress = false
		else:
			next_line()

extends Control

onready var npc_name_box = $ColorRect/HBoxContainer/NpcContainer/NpcTextContainer/NpcName
onready var npc_dialogue_box = $ColorRect/HBoxContainer/NpcContainer/NpcTextContainer/NpcDialogue

onready var player_choice_1_box = $ColorRect/HBoxContainer/PlayerDialogueContainer/PlayerDialogueVBox/Choice1
onready var player_choice_2_box = $ColorRect/HBoxContainer/PlayerDialogueContainer/PlayerDialogueVBox/Choice2
onready var player_choice_3_box = $ColorRect/HBoxContainer/PlayerDialogueContainer/PlayerDialogueVBox/Choice3
onready var player_choice_4_box = $ColorRect/HBoxContainer/PlayerDialogueContainer/PlayerDialogueVBox/Choice4
onready var player_choice_boxes = [player_choice_1_box, player_choice_2_box, player_choice_3_box, player_choice_4_box]

export (String, FILE, "*json") var text_file_ref

var all_text = {}
var settlement_text = {}
var player_current_text = []
var in_progress = false
var current_branch = 0


func _ready() -> void:

	all_text = load_scene_text()

	# TODO: Serialize the settlement name
	settlement_text = all_text["settlement1"]

	process_new_dialogue()

func load_scene_text():
	var temp_file = File.new()
	if temp_file.file_exists(text_file_ref):
		temp_file.open(text_file_ref, File.READ)
		return parse_json(temp_file.get_as_text())


# Every time a dialogue action is taken, this function is called
func process_new_dialogue():
	if in_progress:
		# TODO: implement dialogue end state
		if true:
			update_dialogue()
		else:
			in_progress = false
	else:
		
		in_progress = true
		npc_name_box.text = settlement_text["NPC"]["Name"] 
		update_dialogue()
	
			
func update_dialogue():
	npc_dialogue_box.text = settlement_text["NPC"]["Branches"][str(current_branch)]
	player_current_text = settlement_text["Player"]["Branches"][str(current_branch)]

	var  i = 0
	for box in player_choice_boxes:

		if i > player_current_text.size() - 1:
			box.text = ""
		else:
			box.text = player_current_text[i]

		i += 1


func finish_dialogue():
	in_progress = false
	current_branch = 0


# Signals
func _on_GoodbyeChoice_gui_input(event:InputEvent):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):

		finish_dialogue()
		EventManager.emit_signal("pop_menu")


# TODO: adapt hard coded setup of current_branch to a flexible solution
func _on_Choice1_gui_input(event:InputEvent):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		current_branch = 1
		process_new_dialogue()

func _on_Choice2_gui_input(event:InputEvent):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		current_branch = 2
		process_new_dialogue()

func _on_Choice3_gui_input(event:InputEvent):
	if (event is InputEventMouseButton && event.pressed && event.button_index == 1):
		current_branch = 3
		process_new_dialogue()

func _on_Choice4_gui_input(_event:InputEvent):
	pass # Replace with function body.

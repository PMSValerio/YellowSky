extends VBoxContainer
class_name StatDetails

signal action_pressed

onready var action_button = $HBoxContainer/VBoxContainer/HBoxContainer2/Button

var tex = -1
var tooltip = ""
var current = 0
var maximum = 100
var action = "Action"
var size = 64


func _ready() -> void:
	populate_data()


func init(texture, tool_tip, current_amount, max_amount, action_name, siz = 64) -> void:
	tex = texture
	tooltip = tool_tip
	current = current_amount
	maximum = max_amount
	action = action_name
	size = siz


func init_resource(rec_id, current_amount, max_amount, action_name, siz = 48) -> void:
	tex = Global.resource_icons[rec_id]
	tooltip = Global.resource_names[rec_id]
	current = current_amount
	maximum = max_amount
	action = action_name
	size = siz


func populate_data() -> void:
	set_icon(tex, tooltip)
	set_x_out_of_y(current, maximum)
	set_action(action)


func set_icon(texture, tool_tip) -> void:
	if texture == null or texture is Texture:
		$HBoxContainer/Icon.init_manual(texture, tool_tip, size)
		$HBoxContainer/Icon.visible = texture != null


func set_x_out_of_y(current_amount, max_amount) -> void:
	$HBoxContainer/VBoxContainer/HBoxContainer2/Numerical.text = str(current_amount) + " / " + str(max_amount)
	
	$HBoxContainer/VBoxContainer/ProgressBar.max_value = max_amount
	$HBoxContainer/VBoxContainer/ProgressBar.value = current_amount


func set_action(action_name) -> void:
	action_button.text = action_name


func _on_Button_pressed() -> void:
	emit_signal("action_pressed")

extends VBoxContainer
class_name StatDetails

signal action_pressed

onready var action_button = $HBoxContainer2/Button

var tex = -1
var current = 0
var maximum = 100
var action = "Action"


func _ready() -> void:
	populate_data()


func init(texture, current_amount, max_amount, action_name) -> void:
	tex = texture
	current = current_amount
	maximum = max_amount
	action = action_name


func populate_data() -> void:
	set_icon(tex)
	set_x_out_of_y(current, maximum)
	set_action(action)


func set_icon(texture) -> void:
	if texture == null or texture is Texture:
		$HBoxContainer/Icon.texture = texture


func set_x_out_of_y(current_amount, max_amount) -> void:
	$HBoxContainer2/Numerical.text = str(current_amount) + " / " + str(max_amount)
	
	$HBoxContainer/ProgressBar.max_value = max_amount
	$HBoxContainer/ProgressBar.value = current_amount


func set_action(action_name) -> void:
	action_button.text = action_name


func _on_Button_pressed() -> void:
	emit_signal("action_pressed")

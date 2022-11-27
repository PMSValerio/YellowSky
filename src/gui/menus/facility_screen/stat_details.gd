extends VBoxContainer
class_name StatDetails

onready var action_button = $HBoxContainer2/Button

var tex = -1
var current = 0
var maximum = 0
var action = "Action"

var _target = null
var _func_name = ""
var _binds = []


func _ready() -> void:
	populate_data()


func init(texture, current_amount, max_amount, action_name) -> void:
	tex = texture
	current = current_amount
	maximum = max_amount
	action = action_name


func init_button_signal(target, func_name, binds) -> void:
	_target = target
	_func_name = func_name
	_binds = binds


func populate_data() -> void:
	set_icon(tex)
	set_x_out_of_y(current, maximum)
	set_action(action)
	
	if _target != null:
		action_button.connect("pressed", _target, _func_name, _binds)


func set_icon(texture) -> void:
	if texture != -1:
		$HBoxContainer/Icon.texture = texture


func set_x_out_of_y(current_amount, max_amount) -> void:
	$HBoxContainer2/Numerical.text = str(current_amount) + " / " + str(max_amount)
	
	$HBoxContainer/ProgressBar.value = current_amount
	$HBoxContainer/ProgressBar.max_value = max_amount


func set_action(action_name) -> void:
	action_button.text = action_name

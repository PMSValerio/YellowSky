extends PanelContainer


signal value_chosen(delta_value)

onready var debouncer = $Debouncer

onready var icon = $VBoxContainer/HBoxContainer2/ResourceIcon
onready var balance = $VBoxContainer/HBoxContainer2/PlayerBalance
onready var slider = $VBoxContainer/HBoxContainer/HSlider
onready var input_box = $VBoxContainer/HBoxContainer/SpinBox
onready var confirm = $VBoxContainer/ConfirmButton


# the debouncer timer ensures that _on_value_changed isn't called exceedingly
var debounce_flag = true
var debounce_interval = 0.005

var min_value = 25
var max_value = 75


func set_state(outer_min, outer_max, inner_min, inner_max, texture : Texture) -> void:
	slider.min_value = outer_min
	input_box.min_value = outer_min
	slider.max_value = outer_max
	input_box.max_value = outer_max
	
	min_value = inner_min
	max_value = inner_max
	
	icon.texture = texture
	
	debounce_flag = true # manually force editable
	_on_value_changed(min_value)


func _on_Debouncer_timeout() -> void:
	debounce_flag = true


func _on_value_changed(value: float) -> void:
	if debounce_flag:
		debounce_flag = false
		debouncer.start(debounce_interval)
		
		var clamped = clamp(value, min_value, max_value)
		slider.value = clamped
		input_box.value = clamped
		
		balance.text = str(max_value - input_box.value)


func _on_ConfirmButton_pressed() -> void:
	emit_signal("value_chosen", input_box.value - min_value)
	visible = false

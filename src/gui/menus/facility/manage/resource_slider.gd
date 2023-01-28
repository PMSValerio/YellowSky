extends PanelContainer


signal value_chosen(delta_value)

onready var debouncer = $Debouncer

onready var icon = $MarginContainer/VBoxContainer/HBoxContainer2/ResourceIcon
onready var player_value_label = $MarginContainer/VBoxContainer/HBoxContainer2/GridContainer/PlayerValue
onready var destination_label = $MarginContainer/VBoxContainer/HBoxContainer2/GridContainer/DestinationLabel
onready var facility_value_label = $MarginContainer/VBoxContainer/HBoxContainer2/GridContainer/FacilityValue
onready var slider = $MarginContainer/VBoxContainer/HBoxContainer/HSlider
onready var input_box = $MarginContainer/VBoxContainer/HBoxContainer/SpinBox
onready var confirm = $MarginContainer/VBoxContainer/ConfirmButton


# the debouncer timer ensures that _on_value_changed isn't called exceedingly
var debounce_flag = true
var debounce_interval = 0.005

var min_value = 0
var max_value = 75

var _player_balance = 0
var _faciity_balance = 0


func set_state(player_value, facility_value, facility_max, texture : Texture, destination : String = "Facility", slider_step : int = 1) -> void:
	var fac_missing = facility_max - facility_value # the missing amount of the resource on the facility
	
	min_value = 0
	max_value = min(fac_missing, player_value)
	_player_balance = player_value
	_faciity_balance = facility_value
	
	slider.min_value = 0
	input_box.min_value = 0
	slider.max_value = fac_missing
	input_box.max_value = fac_missing
	
	destination_label.text = destination
	icon.texture = texture
	slider.step = slider_step
	
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
		
		#balance.text = str(max_value - input_box.value)
		player_value_label.text = str(_player_balance - input_box.value)
		facility_value_label.text = str(_faciity_balance + input_box.value)


func _on_ConfirmButton_pressed() -> void:
	emit_signal("value_chosen", input_box.value)
	visible = false


func _on_ExitBtn_pressed() -> void:
	emit_signal("value_chosen", 0)
	visible = false

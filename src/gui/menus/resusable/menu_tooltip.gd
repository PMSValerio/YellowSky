extends Control


export(String) var TOOLTIP_TEXT = "Tooltip"

onready var panel = $PanelContainer
onready var idle_timer = $IdleTimer

var mouse_in = false
var mouse_pos : Vector2 = Vector2.ZERO


func _ready() -> void:
	var _v = get_parent().connect("mouse_entered", self, "_on_mouse_entered_parent")
	_v = get_parent().connect("mouse_exited", self, "_on_mouse_exited_parent")
	
	$PanelContainer/Tooltip.text = TOOLTIP_TEXT


func _physics_process(_delta: float) -> void:
	if mouse_in: # only relevant if mouse is inside
		var new_mouse_pos = get_viewport().get_mouse_position()
		if new_mouse_pos.is_equal_approx(mouse_pos):
			if not panel.visible and idle_timer.time_left == 0.0:
				idle_timer.start()
		else:
			panel.visible = false
			idle_timer.stop()
		mouse_pos = new_mouse_pos


func _on_mouse_entered_parent() -> void:
	mouse_in = true
	mouse_pos = get_viewport().get_mouse_position()


func _on_mouse_exited_parent() -> void:
	mouse_in = false


func _on_IdleTimer_timeout() -> void:
	if mouse_in:
		panel.visible = true

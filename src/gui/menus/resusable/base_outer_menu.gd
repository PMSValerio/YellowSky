extends Control


onready var tabs = $MarginContainer/PanelContainer/TabContainer

var _context = null
var _readied = false


func _ready() -> void:
	_readied = true
	set_context(_context)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ctrl_main_menu"):
		EventManager.emit_signal("pop_menu")
		get_tree().set_input_as_handled()


func set_context(context) -> void:
	_context = context
	if _readied:
		for tab in tabs.get_children():
			if tab.has_method("set_context"):
				tab.set_context(_context)


func _on_ExitBtn_pressed() -> void:
	EventManager.emit_signal("pop_menu")

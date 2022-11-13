extends CanvasLayer


# preloaded menu scenes
var _menus = {
	Global.Menus.TEST: preload("res://src/gui/menus/TestUI.tscn"),
	Global.Menus.SUBTEST: preload("res://src/gui/menus/SubTestUI.tscn"),
	Global.Menus.CHOOSE_FACILITY: preload("res://src/gui/menus/facility_type/FacilityType.tscn"),
	Global.Menus.FACILITY_SCREEN: preload("res://src/gui/menus/facility_screen/FacilityScreen.tscn")
}

# the stack of loaded menus, when empty, game should process normally
var menu_stack = []


func _ready() -> void:
	var _v = EventManager.connect("push_menu", self, "_on_push_menu")
	_v = EventManager.connect("pop_menu", self, "_on_pop_menu")


func _get_menu_scene(menu):
	return _menus[menu].instance()


func _on_push_menu(menu, context):
	if menu in _menus:
		var new_menu = _get_menu_scene(menu)
		menu_stack.push_back(menu)
		
		# TODO: refactor if menus down the stack are still visible, even if inactive
		for child in get_children():
			child.queue_free()
		if new_menu.has_method("set_context"): # if menu has a function to accept context, call it
			new_menu.set_context(context)
		call_deferred("add_child", new_menu)
		# ----------
		
		if not get_tree().paused:
			# TODO: pausing could be handled by the menu
			get_tree().paused = true
	else:
		print("Menu not found")


func _on_pop_menu():
	if not menu_stack.empty():
		var _popped = menu_stack.pop_back()
		for child in get_children():
			child.queue_free()
		# TODO: properly process popped menu
		
		if menu_stack.empty():
			# TODO: pausing could be handled by the menu
			get_tree().paused = false
		else:
			var new_menu = _get_menu_scene(menu_stack.back())
			
			call_deferred("add_child", new_menu)
